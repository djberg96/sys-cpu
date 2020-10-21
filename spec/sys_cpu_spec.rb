#######################################################################
# sys_cpu_spec.rb
#
# This isn't a test file, just a file that require's the appropriate
# test file base on the platform you're on.
#######################################################################
require 'rbconfig'
require 'test_sys_cpu_version'

case RbConfig::CONFIG['host_os']
  when /bsd|darwin|mach|osx/i
    require 'sys_cpu_bsd_spec'
  when /hpux/i
    require 'sys_cpu_hpux_spec'
  when /linux/i
    require 'sys_cpu_linux_spec'
  when /sunos|solaris/i
    require 'sys_cpu_sunos_spec'
  when /mswin|win32|dos|mingw|cygwin/i
    require 'sys_cpu_windows_spec'
  else
    raise "Platform not supported"
end
