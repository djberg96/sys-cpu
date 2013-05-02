require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'sys-cpu'
  spec.version   = '0.7.0'
  spec.author    = 'Daniel J. Berger'
  spec.email     = 'djberg96 at nospam at gmail dot com'
  spec.homepage  = 'http://www.rubyforge.org/projects/sysutils'
  spec.platform  = Gem::Platform::RUBY
  spec.summary   = 'A Ruby interface for providing CPU information'
  spec.test_file = 'test/test_sys_cpu.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.rubyforge_project = 'sysutils'
  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']

  spec.add_dependency('ffi', '>= 1.0.0')
  spec.add_development_dependency('test-unit', '>= 2.4.0')

  spec.description = <<-EOF
    The sys-cpu library provides an interface for gathering information
    about your system's processor(s). Information includes speed, type,
    and load average.
  EOF
end
