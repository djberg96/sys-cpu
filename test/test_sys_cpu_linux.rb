###########################################################
# test_sys_cpu_linux.rb
#
# Test Suite for sys-cpu for Linux. This should be run via
# the 'rake test' task.
###########################################################
require 'sys/cpu'
require 'test-unit'
require 'test_sys_cpu_version'

class TC_Sys_CPU_Linux < Test::Unit::TestCase
  test "dynamic methods are defined as expected" do
    assert_nothing_raised{
      Sys::CPU.processors{ |cs|
        cs.members.each{ |m| cs[m].to_s }
      }
    }
  end

  test "load average works as expected" do
    assert_nothing_raised{ Sys::CPU.load_avg }
    assert_equal(3, Sys::CPU.load_avg.length)
  end

  test "cpu_stats works as expected" do
    assert_nothing_raised{ Sys::CPU.cpu_stats }
    assert_kind_of(Hash, Sys::CPU.cpu_stats)
    assert_true(Sys::CPU.cpu_stats['cpu0'].length >= 4)
  end

  test "architecture works as expected" do
    assert_nothing_raised{ Sys::CPU.architecture }
    assert_kind_of(String, Sys::CPU.architecture)
  end

  test "model works as expected" do
    assert_nothing_raised{ Sys::CPU.model }
    assert_kind_of(String, Sys::CPU.model)
  end

  test "freq works as expected" do
    assert_nothing_raised{ Sys::CPU.freq }
    assert_kind_of(Numeric, Sys::CPU.freq)
  end

  test "num_cpu works as expected" do
    assert_nothing_raised{ Sys::CPU.num_cpu }
    assert_kind_of(Numeric, Sys::CPU.num_cpu)
  end

  test "bogus methods are not picked up by method_missing" do
    assert_raise(NoMethodError){ Sys::CPU.bogus }
  end
end
