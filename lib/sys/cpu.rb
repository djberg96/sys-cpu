# frozen_string_literal: true

# This is just a stub file that requires the appropriate version
# depending on which platform you're on.
require 'rbconfig'

module Sys
  class CPU
    # The version of the sys-cpu gem.
    VERSION = '1.0.3'.freeze
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
