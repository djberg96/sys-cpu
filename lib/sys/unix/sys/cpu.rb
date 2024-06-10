# frozen_string_literal: true

require 'ffi'
require 'rbconfig'

# The Sys module is a name space only.
module Sys
  # The CPU class encapsulates information about the physical CPU's on your system.
  class CPU
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # Error raised if any of the CPU methods fail.
    class Error < StandardError; end

    CTL_HW = 6 # Generic hardware/cpu

    HW_MACHINE      = 1  # Machine class
    HW_MODEL        = 2  # Specific machine model
    HW_NCPU         = 3  # Number of CPU's
    HW_CPU_FREQ     = 15 # CPU frequency

    private_constant :CTL_HW, :HW_MACHINE, :HW_MODEL, :HW_NCPU, :HW_CPU_FREQ

    if RbConfig::CONFIG['host_os'] =~ /bsd|dragonfly/
      HW_MACHINE_ARCH = 11 # Machine architecture
    else
      HW_MACHINE_ARCH = 12 # Machine architecture
    end

    private_constant :HW_MACHINE_ARCH

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
    CPU_TYPE_SPARC     = 14
    CPU_TYPE_POWERPC   = 18
    CPU_TYPE_POWERPC64 = CPU_TYPE_POWERPC | CPU_ARCH_ABI64

    private_constant :CPU_ARCH_ABI64, :CPU_TYPE_X86, :CPU_TYPE_X86_64
    private_constant :CPU_TYPE_SPARC, :CPU_TYPE_POWERPC, :CPU_TYPE_POWERPC64

    begin
      attach_function(
        :sysctl,
        %i[pointer uint pointer pointer pointer size_t],
        :int
      )
      private_class_method :sysctl
    rescue FFI::NotFoundError
      # Do nothing, not supported on this platform.
    end

    begin
      attach_function(
        :sysctlbyname,
        %i[string pointer pointer pointer size_t],
        :int
      )
      private_class_method :sysctlbyname
    rescue FFI::NotFoundError
      # Do nothing, not supported on this platform.
    end

    # Solaris
    begin
      attach_function :getloadavg, %i[pointer int], :int
      attach_function :processor_info, %i[int pointer], :int
      attach_function :sysconf, [:int], :long
      attach_function :sysinfo, %i[int pointer long], :int

      private_class_method :getloadavg
      private_class_method :processor_info
      private_class_method :sysconf
      private_class_method :sysinfo
    rescue FFI::NotFoundError
      # Do nothing, not supported on this platform.
    end

    class ProcInfo < FFI::Struct
      layout(
        :pi_state, :int,
        :pi_processor_type, [:char, 16],
        :pi_fputypes, [:char, 32],
        :pi_clock, :int
      )
    end

    # Returns the cpu's architecture. On most systems this will be identical
    # to the CPU.machine method. On OpenBSD it will be identical to the CPU.model
    # method.
    #
    def self.architecture
      if respond_to?(:sysinfo, true)
        buf = 0.chr * 257

        if sysinfo(SI_ARCHITECTURE, buf, buf.size) < 0
          raise Error, 'sysinfo function failed'
        end

        buf.strip
      elsif respond_to?(:sysctlbyname, true)
        optr = FFI::MemoryPointer.new(:char, 256)
        size = FFI::MemoryPointer.new(:size_t)

        size.write_int(optr.size)

        if sysctlbyname('hw.machine_arch', optr, size, nil, 0) < 0
          raise Error, 'sysctlbyname function failed'
        end

        optr.read_string
      else
        buf  = 0.chr * 64
        mib  = FFI::MemoryPointer.new(:int, 2)
        size = FFI::MemoryPointer.new(:long, 1)

        mib.write_array_of_int([CTL_HW, HW_MACHINE_ARCH])
        size.write_int(buf.size)

        if sysctl(mib, 2, buf, size, nil, 0) < 0
          raise Error, 'sysctl function failed'
        end

        buf.strip
      end
    end

    # Returns the number of cpu's on your system. Note that each core on
    # multi-core systems are counted as a cpu, e.g. one dual core cpu would
    # return 2, not 1.
    #
    def self.num_cpu
      if respond_to?(:sysctlbyname, true)
        optr = FFI::MemoryPointer.new(:long)
        size = FFI::MemoryPointer.new(:size_t)

        size.write_long(optr.size)

        if sysctlbyname('hw.ncpu', optr, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed'
        end

        optr.read_long
      elsif respond_to?(:sysconf, true)
        num = sysconf(SC_NPROCESSORS_ONLN)

        if num < 0
          raise Error, 'sysconf function failed'
        end

        num
      else
        buf  = 0.chr * 4
        mib  = FFI::MemoryPointer.new(:int, 2)
        size = FFI::MemoryPointer.new(:long, 1)

        mib.write_array_of_int([CTL_HW, HW_NCPU])
        size.write_int(buf.size)

        if sysctl(mib, 2, buf, size, nil, 0) < 0
          raise Error, 'sysctl function failed'
        end

        buf.strip.unpack1('C')
      end
    end

    # Returns the cpu's class type. On most systems this will be identical
    # to the CPU.architecture method. On OpenBSD it will be identical to the
    # CPU.model method.
    #
    def self.machine
      if respond_to?(:sysctl, true)
        buf  = 0.chr * 32
        mib  = FFI::MemoryPointer.new(:int, 2)
        size = FFI::MemoryPointer.new(:long, 1)

        mib.write_array_of_int([CTL_HW, HW_MACHINE])
        size.write_int(buf.size)

        if sysctl(mib, 2, buf, size, nil, 0) < 0
          raise Error, 'sysctl function failed'
        end
      else
        buf = 0.chr * 257

        if sysinfo(SI_MACHINE, buf, buf.size) < 0
          raise Error, 'sysinfo function failed'
        end
      end

      buf.strip
    end

    # Returns a string indicating the cpu model.
    #
    def self.model
      if respond_to?(:sysctl, true)
        buf  = 0.chr * 64
        mib  = FFI::MemoryPointer.new(:int, 2)
        size = FFI::MemoryPointer.new(:long, 1)

        mib.write_array_of_int([CTL_HW, HW_MODEL])
        size.write_int(buf.size)

        if sysctl(mib, 2, buf, size, nil, 0) < 0
          raise Error, 'sysctl function failed'
        end

        buf.strip
      else
        pinfo = ProcInfo.new

        # Some systems start at 0, some at 1
        if processor_info(0, pinfo) < 0 && processor_info(1, pinfo) < 0
          raise Error, 'processor_info function failed'
        end

        pinfo[:pi_processor_type].to_s
      end
    end

    # Returns an integer indicating the speed of the CPU.
    #
    def self.freq
      if respond_to?(:sysctlbyname, true)
        optr = FFI::MemoryPointer.new(:long)
        size = FFI::MemoryPointer.new(:size_t)

        size.write_long(optr.size)

        if RbConfig::CONFIG['host_os'] =~ /bsd|dragonfly/i
          name = 'hw.clockrate'
        else
          name = 'hw.cpufrequency'
        end

        if sysctlbyname(name, optr, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed'
        end

        optr.read_long
      elsif respond_to?(:sysctl, true)
        buf  = 0.chr * 16
        mib  = FFI::MemoryPointer.new(:int, 2)
        size = FFI::MemoryPointer.new(:long, 1)

        mib.write_array_of_int([CTL_HW, HW_CPU_FREQ])
        size.write_int(buf.size)

        if sysctl(mib, 2, buf, size, nil, 0) < 0
          raise Error, 'sysctl function failed'
        end

        buf.unpack1('I*') / 1_000_000
      else
        pinfo = ProcInfo.new

        # Some systems start at 0, some at 1
        if processor_info(0, pinfo) < 0 && processor_info(1, pinfo) < 0
          raise Error, 'processor_info function failed'
        end

        pinfo[:pi_clock].to_i
      end
    end

    # Returns an array of three floats indicating the 1, 5 and 15 minute load
    # average.
    #
    def self.load_avg
      return unless respond_to?(:getloadavg, true)
      loadavg = FFI::MemoryPointer.new(:double, 3)
      raise Error, 'getloadavg function failed' if getloadavg(loadavg, loadavg.size) < 0
      loadavg.get_array_of_double(0, 3)
    end

    # Returns the floating point processor type.
    #
    # Not supported on all platforms.
    #
    def self.fpu_type
      raise NoMethodError unless respond_to?(:processor_info, true)

      pinfo = ProcInfo.new

      # Some start at 0, some start at 1
      if processor_info(0, pinfo) < 0 && processor_info(1, pinfo) < 0
        raise Error, 'processor_info function failed'
      end

      pinfo[:pi_fputypes].to_s
    end

    # Returns the current state of processor +num+, or 0 if no number is
    # specified.
    #
    # Not supported on all platforms.
    #
    def self.state(num = 0)
      raise NoMethodError unless respond_to?(:processor_info, true)

      pinfo = ProcInfo.new

      if processor_info(num, pinfo) < 0
        raise Error, 'processor_info function failed'
      end

      case pinfo[:pi_state].to_i
        when P_ONLINE
          'online'
        when P_OFFLINE
          'offline'
        when P_POWEROFF
          'poweroff'
        when P_FAULTED
          'faulted'
        when P_NOINTR
          'nointr'
        when P_SPARE
          'spare'
        else
          'unknown'
      end
    end
  end
end
