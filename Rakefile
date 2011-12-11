require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.rbx')

namespace 'gem' do
  desc "Create the sys-cpu gem"
  task :create => [:clean] do
    spec = eval(IO.read('sys-cpu.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the sys-cpu gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

Rake::TestTask.new do |t|
  if CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|windows/i
    t.libs << 'lib/windows'
  elsif CONFIG['host_os'] =~ /linux/i
    t.libs << 'lib/linux'
  else
    t.libs << 'lib/unix'
  end

  t.libs << 'test'
  t.test_files = FileList['test/test_sys_cpu.rb']
end

task :default => :test
