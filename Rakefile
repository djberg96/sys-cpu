require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include RbConfig

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.rbx')

namespace 'gem' do
  desc "Create the sys-cpu gem"
  task :create => [:clean] do
    spec = eval(IO.read('sys-cpu.gemspec'))
    if Gem::VERSION.to_f < 2.0
      Gem::Builder.new(spec).build
    else
      require 'rubygems/package'
      Gem::Package.build(spec)
    end
  end

  desc "Install the sys-cpu gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

desc "Run the example program"
task :example => [:clean] do
  case CONFIG['host_os']
  when /bsd|darwin|osx/i
    file = "examples/example_sys_cpu_bsd.rb"
    sh "ruby -Ilib/unix #{file}"
  when /hpux/i
    file = "examples/example_sys_cpu_hpux.rb"
    sh "ruby -Ilib/unix #{file}"
  when /linux/i
    file = "examples/example_sys_cpu_linux.rb"
    sh "ruby -Ilib/linux #{file}"
  when /windows|win32|cygwin|mingw|dos/i
    file = "examples/example_sys_cpu_windows.rb"
    sh "ruby -Ilib/windows #{file}"
  when /sunos|solaris/i
    file = "examples/example_sys_cpu_sunos.rb"
    sh "ruby -Ilib/unix #{file}"
  end

end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test_sys_cpu.rb']
end

task :default => :test
