# frozen_string_literal: true

require 'rspec'
require 'sys_cpu_spec'

RSpec.configure do |config|
  config.filter_run_excluding(:bsd) if RbConfig::CONFIG['host_os'] !~ /bsd|darwin|mach|osx/i
  config.filter_run_excluding(:sunos) if RbConfig::CONFIG['host_os'] !~ /sunos|solaris/i
  config.filter_run_excluding(:windows) if RbConfig::CONFIG['host_os'] !~ /mswin|win32|dos|mingw|cygwin/i
  config.filter_run_excluding(:hpux) if RbConfig::CONFIG['host_os'] !~ /hpux/i
  config.filter_run_excluding(:linux) if RbConfig::CONFIG['host_os'] !~ /linux/i
end
