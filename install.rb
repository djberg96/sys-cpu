#######################################################################
# install.rb
#
# For pure Ruby versions only. Generally speaking this script should
# not be run directly. Use the 'rake install' task instead.
#######################################################################
require 'rbconfig'
require 'fileutils'
include Config
install_dir = File.join(CONFIG['sitelibdir'], 'sys')

file = ""

case CONFIG['host_os']
  when /windows|win32|mingw|cygwin|dos/i
    file = "lib/windows/sys/cpu.rb"
  when /linux/i
    file = "lib/linux/sys/cpu.rb"
  when /hpux|freebsd|dragonfly/i
    STDERR.puts "Use 'extconf.rb/make/make site-install' for this platform"
    exit
  else
    STDERR.puts "This platform is not currently supported.  Exiting..."
    exit
end

#######################################################################
# Dynamically generate some of the documentation for linux.  If the
# doc size is already greater than 1.4k, assume that the documentation
# has already been written at some point previously and skip it.
#######################################################################
if CONFIG['host_os'] =~ /linux/
  cpu_file  = "/proc/cpuinfo"
  text_file = "doc/linux.md"
  rb_file   = "lib/linux/sys/cpu.rb"

  if File.size(text_file) > 1400
    puts "You appear to have already created the documentation."
    puts "Skipping..."
  else
    puts "Dynamically generating documentation..."
    fh = File.open(text_file, 'a')

    IO.foreach(cpu_file){ |line|
      next if line =~ /^$/
      k,v = line.split(":")

      v = v.strip.chomp
      k = k.strip.gsub(/\s+/, '_').downcase

      k += "?" if v =~ /yes|no/i

      fh.puts("CPU.#{k}")

      if v =~ /yes|no/i
        k.chop!
        msg = "     Returns true if a " + k.gsub(/_/," ") + "exists on"
        msg << " this system"
        fh.puts(msg)
      else
        fh.puts("     Returns the " + k.gsub(/_/," "))
      end

      fh.puts # Add a blank line
    }

    fh.close
    puts "Documentation creation complete"
  end
end

# Create the 'sys' toplevel directory if it doesn't already exist
begin
  unless File.exist?(install_dir)
    Dir.mkdir(install_dir)
  end
rescue Errno::EACCES => e
  puts "Unable to create #{install_dir}: #{e}"
  exit
end

# Finally, copy the file to the appropriate directory
FileUtils.cp(file, "#{install_dir}/cpu.rb", :verbose => true)

puts "Installation successful"
