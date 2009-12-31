###########################################################
# test_sys_cpu_sunos.rb
#
# Test suite for sys-cpu on Solaris. This should be run
# via the 'rake test' task.
###########################################################
require 'rubygems'
gem 'test-unit'

require 'sys/cpu'
require 'test/unit'
include Sys

class TC_Sys_CPU_SunOS < Test::Unit::TestCase
   def test_cpu_freq
      assert_respond_to(CPU, :freq)
      assert_nothing_raised{ CPU.freq }
      assert_nothing_raised{ CPU.freq(0) }
      assert_kind_of(Integer, CPU.freq(0))
   end

   def test_cpu_type
      assert_respond_to(CPU, :cpu_type)
      assert_nothing_raised{ CPU.cpu_type }
      assert_kind_of(String, CPU.cpu_type)
   end

   def test_fpu_type
      assert_respond_to(CPU, :fpu_type)
      assert_nothing_raised{ CPU.fpu_type }
      assert_kind_of(String, CPU.fpu_type)
   end

   def test_load_avg
      assert_respond_to(CPU, :load_avg)
      assert_nothing_raised{ CPU.load_avg }
      assert_kind_of(Array, CPU.load_avg)
      assert_equal(3, CPU.load_avg.length)
      assert_kind_of(Float, CPU.load_avg.first)
   end

   def test_cpu_model
      assert_respond_to(CPU, :model)
      assert_nothing_raised{ CPU.model }
      assert_kind_of(String, CPU.model)
   end

   def test_num_cpu
      assert_respond_to(CPU, :num_cpu)
      assert_nothing_raised{ CPU.num_cpu }
      assert_kind_of(Integer, CPU.num_cpu)
   end

   def test_state
      assert_respond_to(CPU, :state)
      assert_nothing_raised{ CPU.state }
      assert_nothing_raised{ CPU.state(0) }
      assert_kind_of(String, CPU.state(0))
   end

   def test_expected_errors
      assert_raises(Sys::CPU::Error){ CPU.state(55) }
      assert_raises(TypeError){ CPU.state('yo') }
      assert_raises(Sys::CPU::Error){ CPU.freq(999) }
      assert_raises(TypeError){ CPU.freq('yo') }
   end
end
