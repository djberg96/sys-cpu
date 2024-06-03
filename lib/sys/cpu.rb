# frozen_string_literal: true

# This is just a stub file that requires the appropriate version
# depending on which platform you're on.
require 'rbconfig'

# The Sys module is a namespace only.
module Sys
  # The CPU class encapsulates information about the physical cpu's on your system.
  # This class is reopened for each of the supported platforms/operating systems.
  class CPU
    # The version of the sys-cpu gem.
    VERSION = '1.1.0'

    private_class_method :new
  end
end

case RbConfig::CONFIG['host_os']
  when /linux/i
    require_relative('linux/sys/cpu')
  when /windows|mswin|mingw|cygwin|dos/i
    require_relative('windows/sys/cpu')
  when /darwin|mach|osx/i
    require_relative('darwin/sys/cpu')
  else
    require_relative('unix/sys/cpu')
end
