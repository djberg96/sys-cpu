require 'ffi'
require 'rbconfig'

module Sys
  class CPU
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    CTL_HW     = 6 # Generic hardware/cpu

    HW_MACHINE      = 1  # Machine class
    HW_MODEL        = 2  # Specific machine model
    HW_NCPU         = 3  # Number of CPU's
    HW_MACHINE_ARCH = 12 # CPU frequency
    HW_CPU_FREQ     = 15 # CPU frequency

    attach_function :sysctl, [:pointer, :uint, :pointer, :pointer, :pointer, :size_t], :int
    private_class_method :sysctl

    def self.architecture
      buf  = 0.chr * 64
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_MACHINE_ARCH])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip
    end

    def self.num_cpu
      buf  = 0.chr * 4
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_NCPU])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip.unpack("C").first
    end

    def self.machine
      buf  = 0.chr * 32
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_MACHINE])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip
    end

    def self.model
      buf  = 0.chr * 64
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_MODEL])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip
    end

    def self.freq
      buf  = 0.chr * 16
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_CPU_FREQ])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.unpack("I*").first / 1000000
    end
  end
end
