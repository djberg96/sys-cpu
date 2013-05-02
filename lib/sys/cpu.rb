# This is just a stub file that requires the appropriate version
# depending on which platform you're on.
require 'rbconfig'

case RbConfig::CONFIG['host_os']
  when /linux/i
    require File.join(File.dirname(__FILE__), 'linux', 'sys', 'cpu')
  when /windows|mswin|mingw|cygwin|dos/i
    require File.join(File.dirname(__FILE__), 'windows', 'sys', 'cpu')
  else
    require File.join(File.dirname(__FILE__), 'unix', 'sys', 'cpu')
end
