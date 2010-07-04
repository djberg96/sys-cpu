#######################################################################
# test_sys_cpu_version.rb
#
# The sole purpose of this test case is to verify the version number.
# This reduces the pain of having separate tests for the VERSION
# constant in every single test case.
#######################################################################
require 'rubygems'
gem 'test-unit'

require 'sys/cpu'
require 'test/unit'

class TC_Sys_CPU_VERSION < Test::Unit::TestCase
  def test_version
    assert_equal('0.6.3', Sys::CPU::VERSION)
  end
end
