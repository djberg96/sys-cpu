require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

CLEAN.include(
  '**/*.gem',               # Gem files
  '**/*.rbc',               # Rubinius
  'ext/cpu.c',              # Temporary file
  '**/*.o',                 # C object file
  '**/*.log',               # Ruby extension build log
  '**/Makefile',            # C Makefile
  '**/conftest.dSYM',       # OS X build directory
  "**/*.#{CONFIG['DLEXT']}" # C shared object
)

desc "Build the sys-cpu library on UNIX systems"
task :build => [:clean] do
  Dir.chdir('ext') do
    unless CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|windows|linux/i
      ruby 'extconf.rb'
      sh 'make'
      build_file = 'cpu.' + CONFIG['DLEXT']
      Dir.mkdir('sys') unless File.exists?('sys')
      FileUtils.cp(build_file, 'sys')
    end
  end
end

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

desc "Run the example program"
task :example => [:build] do
  Dir.mkdir('sys') unless File.exists?('sys')
  if CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|windows|linux/i
    if CONFIG['host_os'].match('linux')
      cp 'lib/linux/sys/cpu.rb', 'sys' 
    else
      cp 'lib/windows/sys/cpu.rb', 'sys'
    end
  else
    build_file = 'ext/cpu.' + CONFIG['DLEXT']
    cp build_file, 'sys'
  end

  case CONFIG['host_os']
    when /bsd|darwin|mach|osx/i
      file = 'examples/example_sys_cpu_bsd.rb'
    when /hpux/i
      file = 'examples/example_sys_cpu_hpux.rb'
    when /linux/i
      file = 'examples/example_sys_cpu_linux.rb'
    when /sunos|solaris/i
      file = 'examples/example_sys_cpu_sunos.rb'
    when /mswin|win32|cygwin|mingw|dos/i
      file = 'examples/example_sys_cpu_windows.rb'
  end
  sh "ruby -I. -Iext -Ilib #{file}"
end

Rake::TestTask.new do |t|
  if CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|windows/i
    t.libs << 'lib/windows'
  elsif CONFIG['host_os'] =~ /linux/i
    t.libs << 'lib/linux'
  else
    task :test => :build
    t.libs << 'ext'
    t.libs.delete('lib')
  end

  t.libs << 'test'
  t.test_files = FileList['test/test_sys_cpu.rb']
end

task :default => :test
