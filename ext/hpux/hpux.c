/*****************************************************************************
 * hpux.c (cpu.c) - sys-cpu extension for HP-UX
 *
 * Author: Daniel J. Berger
 *
 * Interface to provide various types of cpu information.
 * Based on the Unix::Processors Perl module (Wilson Snyder) with ideas from
 * Sys::CPU (Matt Sanford) and Solaris::Kstat (Alan Burlison) as well.
 *****************************************************************************/
#include <ruby.h>
#include "version.h"
#include <unistd.h>
#include <sys/pstat.h>

#ifndef PST_MAX_PROCS
#define PST_MAX_PROCS 32
#endif

#ifdef __cplusplus
extern "C"
{
#endif

VALUE cCPUError;

/*
 * call-seq:
 *    CPU.load_avg
 *    CPU.load_avg(cpu_num)
 *    CPU.load_avg{ block }
 *
 * In non-block form returns an array of three floats indicating the 1, 5
 * and 15 minute overall load average.
 *
 * In block form, it returns an array of three floats indicating the 1, 5
 * and 15 minute load average for each cpu.  Only useful on multi-cpu
 * systems.
 *
 * If 'cpu_num' is provided, returns the load average (as a 3-element
 * array) for that cpu only.
 *
 * You cannot provide +cpu_num+ and use block form at the same time.
 */
static VALUE cpu_load_avg(int argc, VALUE *argv)
{
   struct pst_processor psp[PST_MAX_PROCS];
   struct pst_dynamic psd;
   int i, num_cpu;
   VALUE ncpu = Qnil;
   VALUE la_ary = rb_ary_new();

   rb_scan_args(argc,argv,"01",&ncpu);

   if( (ncpu != Qnil) && (rb_block_given_p()) )
   {
      rb_raise(rb_eArgError,"Can't use block form when CPU number is provided");
   }

   if( (ncpu != Qnil) || ((ncpu == Qnil) && (rb_block_given_p())) )
   {
      num_cpu = pstat_getprocessor(psp,sizeof(struct pst_processor),PST_MAX_PROCS,0);
      if(num_cpu < 0)
      {
         rb_raise(cCPUError,"Call to pstat_getprocessor() failed.");
      }
      else
      {
         for(i = 0; i < num_cpu; i++)
         {
            if( (ncpu != Qnil) && (NUM2INT(ncpu)) != i){ continue; }

            rb_ary_push(la_ary,rb_float_new(psp[i].psp_avg_1_min));
            rb_ary_push(la_ary,rb_float_new(psp[i].psp_avg_5_min));
            rb_ary_push(la_ary,rb_float_new(psp[i].psp_avg_15_min));
            if(rb_block_given_p())
            {
               rb_yield(la_ary);
            }
            else
            {
               return la_ary;
            }
            rb_ary_clear(la_ary);
         }
      }
   }
   else
   {
      if(pstat_getdynamic(&psd,sizeof(psd), (size_t)1, 0) == -1)
      {
         rb_raise(cCPUError,"Call to pstat_getdynamic() failed.");
      }
      else
      {
         rb_ary_push(la_ary,rb_float_new(psd.psd_avg_1_min));
         rb_ary_push(la_ary,rb_float_new(psd.psd_avg_5_min));
         rb_ary_push(la_ary,rb_float_new(psd.psd_avg_15_min));
         return la_ary;
      }
   }

   return Qnil;
}

/*
 * call-seq:
 *    CPU.num_cpu
 *
 * Returns the number of CPU's on the system.
 */
static VALUE cpu_num()
{
   struct pst_dynamic dyn;
   pstat_getdynamic(&dyn, sizeof(dyn), 0, 0);
   return INT2NUM(dyn.psd_max_proc_cnt);
}

/* call-seq:
 *    CPU.num_active_cpu
 *
 * Returns the number of active CPU's on the system.
 */
static VALUE cpu_num_active()
{
   struct pst_dynamic dyn;
   pstat_getdynamic(&dyn, sizeof(dyn), 0, 0);
   return INT2NUM(dyn.psd_proc_cnt);
}

/*
 * call-seq:
 *    CPU.architecture
 *
 * Returns the cpu architecture, e.g. PA RISC 1.2, etc, or nil if it
 * cannot be determined.
 */
static VALUE cpu_architecture()
{
   long cpu_ver = sysconf(_SC_CPU_VERSION);

   if(cpu_ver == CPU_HP_MC68020){ return rb_str_new2("Motorola MC68020"); }
   if(cpu_ver == CPU_HP_MC68030){ return rb_str_new2("Motorola MC68030"); }
   if(cpu_ver == CPU_HP_MC68040){ return rb_str_new2("Motorola MC68040"); }
   if(cpu_ver == CPU_PA_RISC1_0){ return rb_str_new2("HP PA-RISC 1.0"); }
   if(cpu_ver == CPU_PA_RISC1_1){ return rb_str_new2("HP PA-RISC 1.1"); }
   if(cpu_ver == CPU_PA_RISC1_2){ return rb_str_new2("HP PA-RISC 1.2"); }
   if(cpu_ver == CPU_PA_RISC2_0){ return rb_str_new2("HP PA-RISC 2.0"); }

   return Qnil;
}

/*
 * call-seq:
 *    CPU.freq(cpu_num=0)
 *
 * Returns an integer indicating the speed (i.e. frequency in Mhz) of
 * +cpu_num+, or CPU 0 if no +cpu_num+ is specified.
 */
static VALUE cpu_freq(int argc, VALUE *argv)
{
   int cpu_num = 0; /* default value */
   struct pst_processor psp;
   unsigned long int clock_speed, scclktick;
   VALUE ncpu = Qnil;

   rb_scan_args(argc, argv, "01", &ncpu);

   if(ncpu != Qnil)
   {
      Check_Type(ncpu,T_FIXNUM);
      cpu_num = NUM2INT(ncpu);
   }

   if((pstat_getprocessor(&psp,sizeof(psp),(size_t)1,cpu_num)) == -1)
      rb_raise(cCPUError, "Invalid CPU number?");

   scclktick=sysconf(_SC_CLK_TCK);
   clock_speed = (psp.psp_iticksperclktick * scclktick) / 1000000;

   /************************************************************************/
   /* It appears that pstat_getprocessor does not return a failure code    */
   /* for an invalid processor number.  So, we'll assume that if the clock */
   /* speed is 0 that an invalid number was provided.                      */
   /************************************************************************/
   if(clock_speed <= 0)
      rb_raise(cCPUError, "Invalid CPU number?");

   return UINT2NUM(clock_speed);
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

   /* 0.6.3: The version of the sys-cpu library */
   rb_define_const(cCPU, "VERSION", rb_str_new2(SYS_CPU_VERSION));

   /* Class Methods */
   rb_define_singleton_method(cCPU, "freq", cpu_freq, -1);
   rb_define_singleton_method(cCPU, "num_cpu", cpu_num, 0);
   rb_define_singleton_method(cCPU, "num_active_cpu", cpu_num_active, 0);
   rb_define_singleton_method(cCPU, "load_avg", cpu_load_avg, -1);
   rb_define_singleton_method(cCPU, "architecture", cpu_architecture, 0);
}

#ifdef __cplusplus
}
#endif
