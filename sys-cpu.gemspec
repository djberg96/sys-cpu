require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'sys-cpu'
  spec.version    = '1.1.0'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.license    = 'Apache-2.0'
  spec.homepage   = 'https://github.com/djberg96/sys-cpu'
  spec.summary    = 'A Ruby interface for providing CPU information'
  spec.test_files = Dir['spec/*.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

  # The ffi dependency is only relevent for the Unix version. Given the
  # ubiquity of ffi these days, I felt a bogus dependency on ffi for Windows
  # and Linux was worth the tradeoff of not having to create 3 separate gems.
  spec.add_dependency('ffi', '~> 1.1')

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rspec', '~> 3.9')
  spec.add_development_dependency('rubocop-rspec')

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/sys-cpu',
    'bug_tracker_uri'       => 'https://github.com/djberg96/sys-cpu/issues',
    'changelog_uri'         => 'https://github.com/djberg96/sys-cpu/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/sys-cpu/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/sys-cpu',
    'wiki_uri'              => 'https://github.com/djberg96/sys-cpu/wiki',
    'rubygems_mfa_required' => 'true',
    'github_repo'           => 'https://github.com/djberg96/sys-cpu'
  }

  spec.description = <<-EOF
    The sys-cpu library provides an interface for gathering information
    about your system's processor(s). Information includes speed, type,
    and load average.
  EOF
end
