require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'sys-cpu'
  spec.version    = '0.7.2'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96 at nospam at gmail dot com'
  spec.license    = 'Artistic 2.0'
  spec.homepage   = 'https://github.com/djberg96/sys-cpu'
  spec.summary    = 'A Ruby interface for providing CPU information'
  spec.test_file  = 'test/test_sys_cpu.rb'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']

  # The ffi dependency is only relevent for the Unix version. Given the
  # ubiquity of ffi these days, I felt a bogus dependency on ffi for Windows
  # and Linux was worth the tradeoff of not having to create 3 separate gems.
  spec.add_dependency('ffi')

  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('rake')

  spec.description = <<-EOF
    The sys-cpu library provides an interface for gathering information
    about your system's processor(s). Information includes speed, type,
    and load average.
  EOF
end
