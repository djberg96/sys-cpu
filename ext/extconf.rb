require "mkmf"
require "fileutils"

File.delete('cpu.c') if File.exists?('cpu.c')

case RUBY_PLATFORM
   when /hpux/i
      FileUtils.cp("hpux/hpux.c", "cpu.c")
   when /sunos|solaris/i
      FileUtils.cp("sunos/sunos.c", "cpu.c")
      unless have_func("getloadavg")
         have_library("kstat")
      end
   when /bsd|darwin/i
      FileUtils.cp("bsd/bsd.c", "cpu.c")
      have_func("sysctlbyname")
      have_library("kvm")
      have_header("kvm.h")
   when /linux|dos|windows|win32|mingw|cygwin/i
      STDERR.puts "Run 'ruby install.rb' instead for this platform"
   else
      STDERR.puts "This platform is not currently supported.  Exiting..."
end

create_makefile("sys/cpu")
