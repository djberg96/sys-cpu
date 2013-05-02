###########################################################
# test_sys_cpu_linux.rb
#
# Test Suite for sys-cpu for Linux. This should be run via
# the 'rake test' task.
###########################################################
require 'sys/cpu'
require 'test-unit'
require 'test_sys_cpu_version'
include Sys

class TC_Sys_CPU_Linux < Test::Unit::TestCase
  def test_all_dynamic_methods
    assert_nothing_raised{
      CPU.processors{ |cs|
        cs.members.each{ |m| cs[m].to_s }
      }
    }
  end

  def test_load_avg
    assert_nothing_raised{ CPU.load_avg }
    assert_equal(3, CPU.load_avg.length)
  end

  def test_cpu_stats
    assert_nothing_raised{ CPU.cpu_stats }
    assert_kind_of(Hash, CPU.cpu_stats)
    assert_equal(true, CPU.cpu_stats['cpu0'].length >= 4)
  end
end
