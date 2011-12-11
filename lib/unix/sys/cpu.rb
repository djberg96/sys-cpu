require 'ffi'

module Sys
  class CPU
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    attach_function :sysctl, [:pointer, :uint, :pointer, :pointer, :pointer, :size_t], :int
    private_class_method :sysctl

    def self.num_cpu
      buf  = 0.chr * 4
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([6, 3])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip.unpack("C").first
    end
  end
end
