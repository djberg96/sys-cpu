#######################################################################
# test_sys_cpu.rb
#
# This isn't a test file, just a file that require's the appropriate
# test file base on the platform you're on.
#######################################################################
require 'rbconfig'
require 'test_sys_cpu_version'

case RbConfig::CONFIG['host_os']
  when /bsd|darwin|mach|osx/i
    require 'test_sys_cpu_bsd'
  when /hpux/i
    require 'test_sys_cpu_hpux'
  when /linux/i
    require 'test_sys_cpu_linux'
  when /sunos|solaris/i
    require 'test_sys_cpu_sunos'
  when /mswin|win32|dos|mingw|cygwin/i
    require 'test_sys_cpu_windows'
  else
    raise "Platform not supported"
end
