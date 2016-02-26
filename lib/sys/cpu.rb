# This is just a stub file that requires the appropriate version
# depending on which platform you're on.
require 'rbconfig'

module Sys
  class CPU
    # The version of the sys-cpu gem.
    VERSION = '0.7.2'
  end
end

case RbConfig::CONFIG['host_os']
  when /linux/i
    require File.join(File.dirname(__FILE__), 'linux', 'sys', 'cpu')
  when /windows|mswin|mingw|cygwin|dos/i
    require File.join(File.dirname(__FILE__), 'windows', 'sys', 'cpu')
  else
    require File.join(File.dirname(__FILE__), 'unix', 'sys', 'cpu')
end
