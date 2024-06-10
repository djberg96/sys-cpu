require 'rake'
require 'rake/clean'
require 'rbconfig'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
include RbConfig

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.rbx', '**/*.lock')

namespace 'gem' do
  desc "Create the sys-cpu gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = Gem::Specification.load('sys-cpu.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc "Install the sys-cpu gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

desc "Run the example program"
task :example => [:clean] do
  case CONFIG['host_os']
  when /bsd|darwin|osx|dragonfly/i
    file = "examples/example_sys_cpu_bsd.rb"
    sh "ruby -Ilib #{file}"
  when /hpux/i
    file = "examples/example_sys_cpu_hpux.rb"
    sh "ruby -Ilib #{file}"
  when /linux/i
    file = "examples/example_sys_cpu_linux.rb"
    sh "ruby -Ilib #{file}"
  when /windows|win32|cygwin|mingw|dos/i
    file = "examples/example_sys_cpu_windows.rb"
    sh "ruby -Ilib #{file}"
  end
end

RuboCop::RakeTask.new

desc "Run the test suite"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
