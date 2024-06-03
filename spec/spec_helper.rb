# frozen_string_literal: true

require 'rspec'
require 'sys_cpu_shared'

RSpec.configure do |config|
  config.include_context(Sys::CPU)
  config.filter_run_excluding(:bsd) if RbConfig::CONFIG['host_os'] !~ /bsd|darwin|mach|osx|dragonfly/i
  config.filter_run_excluding(:windows) if RbConfig::CONFIG['host_os'] !~ /mswin|win32|dos|mingw|cygwin/i
  config.filter_run_excluding(:hpux) if RbConfig::CONFIG['host_os'] !~ /hpux/i
  config.filter_run_excluding(:linux) if RbConfig::CONFIG['host_os'] !~ /linux/i
end
