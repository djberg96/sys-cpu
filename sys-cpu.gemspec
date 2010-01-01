require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'sys-cpu'
  spec.version   = '0.6.2'
  spec.author    = 'Daniel J. Berger'
  spec.email     = 'djberg96 at nospam at gmail dot com'
  spec.homepage  = 'http://www.rubyforge.org/projects/sysutils'
  spec.platform  = Gem::Platform::RUBY
  spec.summary   = 'A Ruby interface for providing CPU information'
  spec.has_rdoc  = true
  spec.test_file = 'test/test_sys_cpu.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('CVS') }

  spec.rubyforge_project = 'sysutils'
  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']

  spec.add_development_dependency('test-unit', '>= 2.0.3')

  spec.description = <<-EOF
    The sys-cpu library provides an interface for gathering information
    about your system's processor(s). Information includes speed, type,
    and load average.
  EOF

  case Config::CONFIG['host_os']
    when /hpux/i
       spec.extra_rdoc_files += ['ext/hpux/hpux.c']
    when /sunos|solaris/i
       spec.extra_rdoc_files += ['ext/sunos/sunos.c']
    when /bsd|darwin|mach|osx/i
       spec.extra_rdoc_files += ['ext/bsd/bsd.c']
  end
   
  case Config::CONFIG['host_os']
    when /mswin|dos|windows|win32|mingw|cygwin/i
      spec.require_paths = ['lib', 'lib/windows']
      spec.extra_rdoc_files << 'lib/sys/cpu.rb'
      spec.platform = Gem::Platform::CURRENT
    when /linux/i
      spec.require_paths = ['lib', 'lib/linux']
      spec.extra_rdoc_files << 'lib/sys/cpu.rb'
      spec.platform = Gem::Platform::CURRENT
    else
      spec.extensions = ['ext/extconf.rb']
   end
end
