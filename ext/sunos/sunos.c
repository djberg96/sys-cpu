/*****************************************************************************
 * sunos.c (cpu.c) - Solaris code sys-cpu
 *
 * Interface to provide various types of cpu information.
 * Based on the Unix::Processors Perl module (Wilson Snyder) with ideas from
 * Sys::CPU (Matt Sanford) and Solaris::Kstat (Alan Burlison) as well.
 *
 * The kstat code for load_avg() was taken largely from a post by Casper Dik
 * on comp.unix.solaris.
 *****************************************************************************/
#include <ruby.h>
#include "version.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/processor.h>
#include <sys/utsname.h>
#include <sys/param.h>
#include <kstat.h>

#ifdef HAVE_GETLOADAVG
#include <sys/loadavg.h>
#endif

/* Missing in older header files */
#ifndef P_POWEROFF
#define P_POWEROFF 5
#endif

#ifdef __cplusplus
extern "C"
{
#endif

VALUE cCPUError;

/*
 * call-seq:
 *    CPU.freq(cpu_num=0)
 *
 * Returns an integer indicating the speed (i.e. frequency in Mhz) of
 * +cpu_num+, or cpu 0 (zero) if no number is provided. If you provide an
 * invalid cpu number then a CPU::Error is raised.
 */
static VALUE cpu_freq(int argc, VALUE *argv)
{
   int ncpu = 0; /* Default value */
   int cpu;
   int last_cpu = 0;
   int clock = 0;
   processor_info_t pi;
   VALUE cpu_num = Qnil;

   rb_scan_args(argc, argv, "01", &cpu_num);

   if(cpu_num != Qnil)
      ncpu = NUM2INT(cpu_num);

   for(cpu = ncpu; cpu < last_cpu+16; cpu++) {
      if(processor_info(cpu, &pi) == 0 && pi.pi_state == P_ONLINE){
         if(clock < pi.pi_clock){
            clock = pi.pi_clock;
         }
         last_cpu = cpu;
      }
   }

   if(clock == 0)
      rb_raise(cCPUError, "Invalid CPU number?");

   return INT2NUM(clock);
}

/*
 * call-seq:
 *    CPU.state(cpu_num=0)
 *
 * Returns a string indicating the cpu state of +cpu_num+, or cpu 0 if no
 * number is specified. Raises a CPU::Error if an invalid +cpu_num+ is provided.
 */
static VALUE cpu_state(int argc, VALUE *argv)
{
   int cpu = 0; /* Default value */
   char* value = NULL;
   processor_info_t pi;
   VALUE cpu_num = Qnil;

   rb_scan_args(argc, argv, "01", &cpu_num);

   if(cpu_num != Qnil)
      cpu = NUM2INT(cpu_num);

   if(processor_info(cpu, &pi) == 0){
       switch (pi.pi_state)
       {
          case P_ONLINE:
             value = "online";
             break;
          case P_OFFLINE:
             value = "offline";
             break;
          case P_POWEROFF:
             value = "poweroff";
             break;
          default:
             value = "unknown";
       }
   }
   else{
      rb_raise(cCPUError, "state() call failed - invalid cpu num?");
   }

   return rb_str_new2(value);
}

/*
 * call-seq:
 *    CPU.num_cpu
 *
 * Returns the number of cpu's on your system.
 */
static VALUE cpu_num()
{
   int num_cpu;
   num_cpu = sysconf(_SC_NPROCESSORS_ONLN);
   return INT2NUM(num_cpu);
}

/*
 * call-seq:
 *    CPU.cpu_type
 *
 * Returns a string indicating the type of processor. This is the
 * architecture (e.g. sparcv9), not the exact model (e.g. Ultra-IIe).
 * Returns nil if not found.
 *--
 * All cpu must be the same type (right?)
 */
static VALUE cpu_type()
{
   int cpu = 0;
   char* value = NULL;
   processor_info_t pi;

   /* Some systems start the cpu num at 0, others start at 1 */
   if(processor_info(cpu, &pi) == 0)
      value = pi.pi_processor_type;
   else if(processor_info(cpu+1, &pi) == 0)
      value = pi.pi_processor_type;
   else
      return Qnil;

   return rb_str_new2(value);
}

/*
 * call-seq:
 *    CPU.fpu_type
 *
 * Returns a string indicating the type of floating point unit, or nil if
 * not found.
 */
static VALUE cpu_fpu_type()
{
   int cpu = 0;
   char* value = NULL;
   processor_info_t pi;

   /* Some systems start the cpu num at 0, others start at 1 */
   if(processor_info(cpu, &pi) == 0)
      value = pi.pi_fputypes;
   else if(processor_info(cpu+1, &pi) == 0)
      value = pi.pi_fputypes;
   else
      return Qnil;

   return rb_str_new2(value);
}

/*
 * call-seq:
 *    CPU.model
 *
 * Returns a string indicating the cpu model. For now, this is the
 * architecture type, rather than the exact model.
 */
static VALUE cpu_model()
{
   struct utsname u;
   uname(&u);
   return rb_str_new2(u.machine);
}

/*
 * call-seq:
 *    CPU.load_avg
 *
 * Returns an array of 3 floats, the load averages for the last 1, 5 and 15
 * minutes.
 */
static VALUE cpu_load_avg()
{
   VALUE la_ary = rb_ary_new();

#ifdef HAVE_GETLOADAVG
   double load_avg[3];

   if(getloadavg(load_avg, sizeof(load_avg)) < 0)
      rb_raise(cCPUError, "getloadavg() error");

   rb_ary_push(la_ary, rb_float_new(load_avg[0]));
   rb_ary_push(la_ary, rb_float_new(load_avg[1]));
   rb_ary_push(la_ary, rb_float_new(load_avg[2]));
#else
   kstat_ctl_t* kc;
   kstat_t* ksp;
   kstat_named_t* kn1;
   kstat_named_t* kn5;
   kstat_named_t* kn15;

   kc = kstat_open();

   if(kc == 0)
      rb_raise(cCPUError, "kstat_open() error");

   ksp = kstat_lookup(kc, "unix", 0, "system_misc");

   if(ksp == 0)
      rb_raise(cCPUError, "kstat_lookup() error");

   if(kstat_read(kc,ksp,0) == -1)
      rb_raise(cCPUError, "kstat_read() error");

   kn1  = kstat_data_lookup(ksp, "avenrun_1min");
   kn5  = kstat_data_lookup(ksp, "avenrun_5min");
   kn15 = kstat_data_lookup(ksp, "avenrun_15min");

   if( (kn1 == 0) || (kn5 == 0) || (kn15 == 0) )
      rb_raise(cCPUError, "kstat_lookup() error");

   rb_ary_push(la_ary, rb_float_new((double)kn1->value.ui32/FSCALE));
   rb_ary_push(la_ary, rb_float_new((double)kn5->value.ui32/FSCALE));
   rb_ary_push(la_ary, rb_float_new((double)kn15->value.ui32/FSCALE));

   kstat_close(kc);
#endif

   return la_ary;
}

void Init_cpu()
{
   VALUE mSys, cCPU;

   /* The Sys module serves as a toplevel namespace only */
   mSys = rb_define_module("Sys");

   /* The CPU class provides class methods for obtaining CPU information */
   cCPU = rb_define_class_under(mSys, "CPU", rb_cObject);

   /* The CPU::Error Exception class is raised whenever any of the CPU class
    * methods fail.
    */
   cCPUError = rb_define_class_under(cCPU, "Error", rb_eStandardError);

   /* 0.6.2: The version of the sys-cpu library */
   rb_define_const(cCPU, "VERSION", rb_str_new2(SYS_CPU_VERSION));

   /* Class Methods */
   rb_define_singleton_method(cCPU, "freq", cpu_freq, -1);
   rb_define_singleton_method(cCPU, "state", cpu_state, -1);
   rb_define_singleton_method(cCPU, "num_cpu", cpu_num, 0);
   rb_define_singleton_method(cCPU, "cpu_type", cpu_type, 0);
   rb_define_singleton_method(cCPU, "fpu_type", cpu_fpu_type, 0);
   rb_define_singleton_method(cCPU, "model", cpu_model, 0);
   rb_define_singleton_method(cCPU, "load_avg", cpu_load_avg, 0);

}

#ifdef __cplusplus
}
#endif
