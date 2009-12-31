#######################################################################
# test_sys_cpu.rb
#
# This isn't a test file, just a file that require's the appropriate
# test file base on the platform you're on.
#######################################################################
require 'rbconfig'
require 'tc_version'

case Config::CONFIG['host_os']
   when /bsd|darwin|mach|osx/i
      require 'tc_bsd'
   when /hpux/i
      require 'tc_hpux'
   when /linux/i
      require 'tc_linux'
   when /sunos|solaris/i
      require 'tc_sunos'
   when /mswin|win32|dos|mingw|cygwin/i
      require 'tc_windows'
   else
      raise "Platform not supported"
end
