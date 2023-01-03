# frozen_string_literal: true

require 'ffi'
require 'rbconfig'

# The Sys module serves as a namespace only.
module Sys
  # The CPU class encapsulates information about the physical cpu's on your system.
  class CPU
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # Error raised if any of the CPU methods fail.
    class Error < StandardError; end

    CTL_HW = 6 # Generic hardware/cpu

    private_constant :CTL_HW

    HW_MACHINE      = 1  # Machine class
    HW_MODEL        = 2  # Specific machine model
    HW_NCPU         = 3  # Number of CPU's
    HW_CPU_FREQ     = 15 # CPU frequency
    HW_MACHINE_ARCH = 12 # Machine architecture

    private_constant :HW_MACHINE, :HW_MODEL, :HW_NCPU, :HW_CPU_FREQ, :HW_MACHINE_ARCH

    SI_MACHINE          = 5
    SI_ARCHITECTURE     = 6
    SC_NPROCESSORS_ONLN = 15

    private_constant :SI_MACHINE, :SI_ARCHITECTURE, :SC_NPROCESSORS_ONLN

    P_OFFLINE  = 1
    P_ONLINE   = 2
    P_FAULTED  = 4
    P_POWEROFF = 5
    P_NOINTR   = 6
    P_SPARE    = 7

    private_constant :P_OFFLINE, :P_ONLINE, :P_FAULTED, :P_POWEROFF, :P_NOINTR, :P_SPARE

    CPU_ARCH_ABI64     = 0x01000000
    CPU_TYPE_X86       = 7
    CPU_TYPE_X86_64    = (CPU_TYPE_X86 | CPU_ARCH_ABI64)
    CPU_TYPE_ARM		   = 12
    CPU_TYPE_SPARC     = 14
    CPU_TYPE_POWERPC   = 18
    CPU_TYPE_POWERPC64 = CPU_TYPE_POWERPC | CPU_ARCH_ABI64
    CPU_TYPE_ARM64     = CPU_TYPE_ARM | CPU_ARCH_ABI64

    private_constant :CPU_ARCH_ABI64, :CPU_TYPE_X86, :CPU_TYPE_X86_64, :CPU_TYPE_ARM
    private_constant :CPU_TYPE_SPARC, :CPU_TYPE_POWERPC, :CPU_TYPE_POWERPC64

    attach_function(
      :sysctl,
      %i[pointer uint pointer pointer pointer size_t],
      :int
    )

    private_class_method :sysctl

    attach_function(
      :sysctlbyname,
      %i[string pointer pointer pointer size_t],
      :int
    )

    private_class_method :sysctlbyname

    attach_function :getloadavg, %i[pointer int], :int
    attach_function :sysconf, [:int], :long

    private_class_method :getloadavg
    private_class_method :sysconf

    class ClockInfo < FFI::Struct
      layout(
        :hz, :int,
        :tick, :int,
        :spare, :int,
        :stathz, :int,
        :profhz, :int
      )
    end

    private_constant :ClockInfo

    # Returns the cpu's architecture. On most systems this will be identical
    # to the CPU.machine method. On OpenBSD it will be identical to the CPU.model
    # method.
    #
    def self.architecture
      optr = FFI::MemoryPointer.new(:char, 256)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_int(optr.size)

      if sysctlbyname('hw.machine', optr, size, nil, 0) < 0
        raise Error, 'sysctlbyname function failed'
      end

      optr.read_string
    end

    # Returns the number of cpu's on your system. Note that each core on
    # multi-core systems are counted as a cpu, e.g. one dual core cpu would
    # return 2, not 1.
    #
    def self.num_cpu
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(optr.size)

      if sysctlbyname('hw.ncpu', optr, size, nil, 0) < 0
        raise Error, 'sysctlbyname failed'
      end

      optr.read_long
    end

    # Returns the cpu's class type. On most systems this will be identical
    # to the CPU.architecture method. On OpenBSD it will be identical to the
    # CPU.model method.
    #
    def self.machine
      buf  = 0.chr * 32
      mib  = FFI::MemoryPointer.new(:int, 2)
      size = FFI::MemoryPointer.new(:long, 1)

      mib.write_array_of_int([CTL_HW, HW_MACHINE])
      size.write_int(buf.size)

      if sysctl(mib, 2, buf, size, nil, 0) < 0
        raise Error, 'sysctl function failed'
      end

      buf.strip
    end

    # Returns a string indicating the cpu model.
    #
    def self.model
      ptr  = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(ptr.size)

      if sysctlbyname('hw.cputype', ptr, size, nil, 0) < 0
        raise 'sysctlbyname function failed'
      end

      case ptr.read_long
        when  CPU_TYPE_X86, CPU_TYPE_X86_64
          'Intel'
        when CPU_TYPE_SPARC
          'Sparc'
        when CPU_TYPE_POWERPC, CPU_TYPE_POWERPC64
          'PowerPC'
        when CPU_TYPE_ARM, CPU_TYPE_ARM64
          'ARM'
        else
          'Unknown'
      end
    end

    # Returns an integer indicating the speed of the CPU.
    #
    def self.freq
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(optr.size)

      if RbConfig::CONFIG['host_cpu'] =~ /^arm|^aarch/i
        if sysctlbyname('hw.tbfrequency', optr, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed on hw.tbfrequency'
        end

        size.clear
        clock = ClockInfo.new
        size.write_long(clock.size)

        if sysctlbyname('kern.clockrate', clock, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed on kern.clockrate'
        end

        (optr.read_long * clock[:hz]) / 1_000_000
      else
        if sysctlbyname('hw.cpufrequency', optr, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed on hw.cpufrequency' if result < 0
        end
        optr.read_long / 1_000_000
      end
    end

    # Returns an array of three floats indicating the 1, 5 and 15 minute load
    # average.
    #
    def self.load_avg
      loadavg = FFI::MemoryPointer.new(:double, 3)

      if getloadavg(loadavg, loadavg.size) < 0
        raise Error, 'getloadavg function failed'
      end

      loadavg.get_array_of_double(0, 3)
    end
  end
end
