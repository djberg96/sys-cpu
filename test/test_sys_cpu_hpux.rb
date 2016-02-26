#####################################################################
# test_sys_cpu_hpux.rb
#
# Test suite for the HP-UX platform. This should be run via the
# 'rake test' task.
#####################################################################
require 'sys/cpu'
require 'test-unit'
require 'test_sys_cpu_version'
include Sys

class TC_Sys_CPU_HPUX < Test::Unit::TestCase
   def test_cpu_freq
      assert_respond_to(CPU, :freq)
      assert_nothing_raised{ CPU.freq }
      assert_nothing_raised{ CPU.freq(0) }
      assert_kind_of(Integer, CPU.freq, 'Invalid Type')
   end

   def test_num_cpu
      assert_respond_to(CPU, :num_cpu)
      assert_nothing_raised{ CPU.num_cpu }
      assert_kind_of(Integer, CPU.num_cpu, 'Invalid Type')
   end

   def test_num_active_cpu
      assert_respond_to(CPU, :num_active_cpu)
      assert_nothing_raised{ CPU.num_active_cpu }
      assert_kind_of(Integer, CPU.num_active_cpu, 'Invalid Type')
   end

   def test_cpu_architecture
      assert_respond_to(CPU, :architecture)
      assert_nothing_raised{ CPU.architecture }
      assert_kind_of(String, CPU.architecture, 'Invalid Type')
   end

   def test_load_avg
      assert_respond_to(CPU, :load_avg)
      assert_nothing_raised{ CPU.load_avg }
      assert_nothing_raised{ CPU.load_avg(0) }
      assert_nothing_raised{ CPU.load_avg{ |e| } }
      assert_raises(ArgumentError){ CPU.load_avg(0){ } }
      assert_kind_of(Array, CPU.load_avg, 'Invalid Type')
      assert_kind_of(Array, CPU.load_avg(0), 'Invalid Type')
      assert_equal(3, CPU.load_avg.length, 'Bad number of elements')
      assert_equal(3, CPU.load_avg(0).length, 'Bad number of elements')
   end
end
