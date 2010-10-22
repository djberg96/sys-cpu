require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'

namespace 'C' do
  desc "Clean the build files for the sys-cpu source for UNIX systems"
  task :clean do
    Dir["**/*.rbc"].each{ |f| File.delete(f) } # Rubinius
    Dir["*.gem"].each{ |f| File.delete(f) }
    
    rm_rf('sys') if File.exists?('sys')
    rm_rf('lib/sys/cpu.rb') if File.exists?('lib/sys/cpu.rb')

    Dir.chdir('ext') do
      unless Config::CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|linux/i
        rm_rf('conftest.dSYM') if File.exists?('conftest.dSYM') # OS X
        rm_rf('sys') if File.exists?('sys')
        rm_rf('cpu.c') if File.exists?('cpu.c')
        build_file = 'cpu.' + Config::CONFIG['DLEXT']
        sh 'make distclean' if File.exists?(build_file)
      end
    end
  end

  desc "Build the sys-cpu library on UNIX systems"
  task :build => [:clean] do
    Dir.chdir('ext') do
      unless Config::CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|linux/i
        ruby 'extconf.rb'
        sh 'make'
        build_file = 'cpu.' + Config::CONFIG['DLEXT']
        Dir.mkdir('sys') unless File.exists?('sys')
        FileUtils.cp(build_file, 'sys')
      end
    end
  end
end

namespace 'gem' do
  desc "Create the sys-cpu gem"
  task :create => ['C:clean'] do
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
  if Config::CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|linux/i
    if Config::CONFIG['host_os'].match('linux')
      cp 'lib/linux/sys/cpu.rb', 'sys' 
    else
      cp 'lib/windows/sys/cpu.rb', 'sys'
    end
  else
    build_file = 'ext/cpu.' + Config::CONFIG['DLEXT']
    cp build_file, 'sys'
  end

  case Config::CONFIG['host_os']
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
  if Config::CONFIG['host_os'] =~ /mswin|win32|mingw|cygwin|dos|windows/i
    t.libs << 'lib/windows'
  elsif Config::CONFIG['host_os'] =~ /linux/i
    t.libs << 'lib/linux'
  else
    task :test => 'C:build'
    t.libs << 'ext'
    t.libs.delete('lib')
  end

  t.libs << 'test'
  t.test_files = FileList['test/test_sys_cpu.rb']
end

task :default => :test
task :clean => 'C:clean'
