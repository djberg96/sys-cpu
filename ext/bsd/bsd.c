/*****************************************************************************
 * bsd.c (cpu.c) - sys-cpu extension for the various BSD flavors and OS X.
 *
 * Author: Daniel J. Berger
 *
 * Interface to provide various types of cpu information.
 * Based on the Unix::Processors Perl module (Wilson Snyder) with ideas from
 * Sys::CPU (Matt Sanford) and Solaris::Kstat (Alan Burlison) as well.
 * OS X 10.5+ patch for uptime by Victor Costan.
 *
 * Portions of this code lifted from the MPlayer source (cpuinfo.c).
 *****************************************************************************/
#include <ruby.h>
#include "version.h"

#ifdef HAVE_KVM_H
#include <kvm.h>
#endif

#if defined (__OpenBSD__)
#include <sys/param.h>
#endif

#include <sys/sysctl.h>
#include <sys/types.h>
#include <string.h>
#include <errno.h>

#ifndef MISSING_USLEEP
#include <unistd.h>
#endif

VALUE cCPUError;

/****************************************************************************
 * Used for FreeBSD 4.x to determine CPU clock speed. Borrowed from cpuinfo.c
 * in the MPlayer source code.
 ****************************************************************************/
#if defined (__FreeBSD__) && (__FreeBSD__ < 5 )
static int64_t rdtsc(void){
   unsigned int i, j;
#define RDTSC  ".byte 0x0f, 0x31; "
   asm(RDTSC : "=a"(i), "=d"(j) : );
   return ((int64_t)j<<32) + (int64_t)i;
}
#endif

/*
 * call-seq:
 *    CPU.load_average
 *
 * Returns an array of three floats indicating the 1, 5 and 15 minute load
 * average.
 */
static VALUE cpu_load_avg(VALUE klass){
   double avgs[3];
   int n, max = 3;
   VALUE v_num_array = rb_ary_new();

#ifdef HAVE_KVM_H
   kvm_t* k;

   k = malloc(sizeof(kvm_t*));

   if(!kvm_getloadavg(k, avgs, max)){
      free(k);
      rb_raise(cCPUError, "error calling kvm_getloadavg(): %s", strerror(errno));
   }

   for(n = 0; n < 3; n++)
      rb_ary_push(v_num_array, rb_float_new(avgs[n]));

   free(k);
#else
	struct loadavg k;
	size_t len = sizeof(k);

#ifdef HAVE_SYSCTLBYNAME
   if(sysctlbyname("vm.loadavg", &k, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctlbyname(): %s", strerror(errno));
#else
   int mib[2];
   mib[0] = CTL_HW;
   mib[1] = VM_LOADAVG;

   if(sysctl(mib, 2, &k, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctl(): %s", strerror(errno));
#endif

   for(n = 0; n < 3; n++)
      rb_ary_push(v_num_array, rb_float_new(k.ldavg[n] / (float)k.fscale));
#endif

   return v_num_array;
}

/*
 * call-seq:
 *    CPU.num_cpu
 *
 * Returns the number of cpu's on your system. Note that each core on
 * multi-core systems are counted as a cpu, e.g. one dual core cpu would
 * return 2, not 1.
 */
static VALUE cpu_num(VALUE klass){
   int num_cpu;
   size_t len = sizeof(num_cpu);

#ifdef HAVE_SYSCTLBYNAME
   if(sysctlbyname("hw.ncpu", &num_cpu, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctlbyname(): %s", strerror(errno));
#else
   int mib[2];
   mib[0] = CTL_HW;
   mib[1] = HW_NCPU;

   if(sysctl(mib, 2, &num_cpu, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctl(): %s", strerror(errno));
#endif

   return INT2NUM(num_cpu);
}

/*
 * call-seq:
 *    CPU.model
 *
 * Returns a string indicating the cpu model.
 */
static VALUE cpu_model(VALUE klass){
   char model[64];
   size_t len = sizeof(model);

#ifdef HAVE_SYSCTLBYNAME
   if(sysctlbyname("hw.model", &model, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctlbyname(): %s", strerror(errno));
#else
   int mib[2];
   mib[0] = CTL_HW;
   mib[1] = HW_MODEL;

   if(sysctl(mib, 2, &model, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctl(): %s", strerror(errno));
#endif

   return rb_str_new2(model);
}

/*
 * call-seq:
 *    CPU.architecture
 *
 * Returns the cpu's architecture. On most systems this will be identical
 * to the CPU.machine method. On OpenBSD it will be identical to the CPU.model
 * method.
 */
static VALUE cpu_architecture(VALUE klass){
   char arch[32];
   size_t len = sizeof(arch);

#ifdef HAVE_SYSCTLBYNAME
#if defined(__MACH__) && defined(__APPLE__)
   if(sysctlbyname("hw.machine", &arch, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctlbyname(): %s", strerror(errno));
#else
   if(sysctlbyname("hw.machine_arch", &arch, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctlbyname(): %s", strerror(errno));
#endif
#else
   int mib[2];
   mib[0] = CTL_VM;
#ifdef HW_MACHINE_ARCH
   mib[1] = HW_MACHINE_ARCH;
#else
   mib[1] = HW_MODEL;
#endif

   if(sysctl(mib, 2, &arch, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctl(): %s", strerror(errno));
#endif

   return rb_str_new2(arch);
}

/*
 * call-seq:
 *    CPU.machine
 *
 * Returns the cpu's class type. On most systems this will be identical
 * to the CPU.architecture method. On OpenBSD it will be identical to the
 * CPU.model method.
 */
static VALUE cpu_machine(VALUE klass){
   char machine[32];
   size_t len = sizeof(machine);

#ifdef HAVE_SYSCTLBYNAME
   if(sysctlbyname("hw.machine", &machine, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctlbyname(): %s", strerror(errno));
#else
   int mib[2];
   mib[0] = CTL_HW;
#ifdef HW_MACHINE_ARCH
   mib[1] = HW_MACHINE;
#else
   mib[1] = HW_MODEL;
#endif

   if(sysctl(mib, 2, &machine, &len, NULL, 0))
      rb_raise(cCPUError, "error calling sysctl(): %s", strerror(errno));
#endif

   return rb_str_new2(machine);
}

/*
 * call-seq:
 *    CPU.freq
 *
 * Returns an integer indicating the speed (i.e. frequency in Mhz) of the cpu.
 *
 * Not supported on OS X.
 *--
 * Not supported on OS X currently. The sysctl() approach returns a bogus
 * hard-coded value.
 *
 * TODO: Fix for OS X.
 */
static VALUE cpu_freq(VALUE klass){
   int mhz;
#if defined (__FreeBSD__) && (__FreeBSD__ < 5)
   int64_t tsc_start, tsc_end;
   struct timeval tv_start, tv_end;
   int usec_delay;

   tsc_start = rdtsc();
   gettimeofday(&tv_start,NULL);
#ifdef MISSING_USLEEP
   sleep(1);
#else
   usleep(100000);
#endif
   tsc_end = rdtsc();
   gettimeofday(&tv_end,NULL);

   usec_delay = 1000000 * (tv_end.tv_sec - tv_start.tv_sec)
      + (tv_end.tv_usec - tv_start.tv_usec);

   mhz = ((tsc_end - tsc_start) / usec_delay);
#else
   size_t len = sizeof(mhz);
#ifdef HAVE_SYSCTLBYNAME
   if(sysctlbyname("hw.clockrate", &mhz, &len, 0, 0))
      rb_raise(cCPUError, "error calling sysctlbyname(): %s", strerror(errno));
#else
   int mib[2];

   mib[0] = CTL_KERN;
   mib[1] = KERN_CLOCKRATE;

   if(sysctl(mib, 2, &mhz, &len, NULL, 0))
      rb_raise(cCPUError,"error calling sysctlbyname(): %s", strerror(errno));
#endif
#endif

   return INT2NUM(mhz);
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
   rb_define_singleton_method(cCPU, "architecture", cpu_architecture, 0);
   rb_define_singleton_method(cCPU, "freq", cpu_freq, 0);
   rb_define_singleton_method(cCPU, "load_avg", cpu_load_avg, 0);
   rb_define_singleton_method(cCPU, "machine", cpu_machine, 0);
   rb_define_singleton_method(cCPU, "model", cpu_model, 0);
   rb_define_singleton_method(cCPU, "num_cpu", cpu_num, 0);
}
