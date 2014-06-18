#######################################################################
# test_sys_cpu_version.rb
#
# The sole purpose of this test case is to verify the version number.
# This reduces the pain of having separate tests for the VERSION
# constant in every single test case.
#######################################################################
require 'sys/cpu'
require 'test-unit'

class TC_Sys_CPU_VERSION < Test::Unit::TestCase
  test "version number is set to the expected value" do
    assert_equal('0.7.2', Sys::CPU::VERSION)
  end
end
