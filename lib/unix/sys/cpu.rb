require 'ffi'

module Sys
  class CPU
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
  end
end
