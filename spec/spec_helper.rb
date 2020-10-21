RSpec.configure do |config|
  config.filter_run_excluding(:bsd) unless RbConfig::CONFIG['host_os'] =~ /bsd|darwin|mach|osx/i
  config.filter_run_excluding(:sunos) unless RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
  config.filter_run_excluding(:windows) unless RbConfig::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  config.filter_run_excluding(:hpux) unless RbConfig::CONFIG['host_os'] =~ /hpux/i
  config.filter_run_excluding(:linux) unless RbConfig::CONFIG['host_os'] =~ /linux/i
end
