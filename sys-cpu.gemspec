require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name      = 'sys-cpu'
   gem.version   = '0.6.2'
   gem.author    = 'Daniel J. Berger'
   gem.email     = 'djberg96 at nospam at gmail dot com'
   gem.homepage  = 'http://www.rubyforge.org/projects/sysutils'
   gem.platform  = Gem::Platform::RUBY
   gem.summary   = 'A Ruby interface for providing CPU information'
   gem.has_rdoc  = true
   gem.test_file = 'test/test_sys_cpu.rb'
   gem.files     = Dir['**/*'].reject{ |f| f.include?('CVS') }

   gem.rubyforge_project = 'sysutils'
   gem.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']

   gem.add_development_dependency('test-unit', '>= 2.0.3')

   gem.description = <<-EOF
      The sys-cpu library provides an interface for gathering information
      about your system's processor(s). Information includes speed, type,
      and load average.
   EOF

   case Config::CONFIG['host_os']
      when /hpux/i
         gem.extra_rdoc_files += ['ext/hpux/hpux.c']
      when /sunos|solaris/i
         gem.extra_rdoc_files += ['ext/sunos/sunos.c']
      when /bsd|darwin|mach|osx/i
         gem.extra_rdoc_files += ['ext/bsd/bsd.c']
   end
   
   case Config::CONFIG['host_os']
      when /mswin|dos|windows|win32|mingw|cygwin/i
         File.rename('lib/sys/windows.rb', 'lib/sys/cpu.rb')
         File.delete('lib/sys/linux.rb')
         gem.extra_rdoc_files << 'lib/sys/cpu.rb'
         gem.platform = Gem::Platform::CURRENT
         gem.files.reject!{ |f| f.include?('ext') }
      when /linux/i
         File.rename('lib/sys/linux.rb', 'lib/sys/cpu.rb')
         File.delete('lib/sys/windows.rb')
         gem.extra_rdoc_files << 'lib/sys/cpu.rb'
         gem.platform = Gem::Platform::CURRENT
         gem.files.reject!{ |f| f.include?('ext') }
      else
         gem.extensions = ['ext/extconf.rb']
   end
end

Gem::Builder.new(spec).build
