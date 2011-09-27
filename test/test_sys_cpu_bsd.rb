#############################################################
# test_sys_cpu_bsd.rb
#
# The test case for sys-cpu on BSD flavors, including OS X.
#############################################################
require 'rubygems'
gem 'test-unit'

require 'sys/cpu'
require 'rbconfig'
require 'test/unit'
require 'test_sys_cpu_version'
include Sys

class TC_Sys_CPU_BSD < Test::Unit::TestCase
   def test_architecture
      assert_respond_to(CPU, :architecture)
      assert_nothing_raised{ CPU.architecture }
      assert_kind_of(String, CPU.architecture)
   end

   def test_architecture_expected_errors
      assert_raises(ArgumentError){ CPU.architecture(0) }
   end

   def test_cpu_freq
      assert_respond_to(CPU, :freq)
      assert_nothing_raised{ CPU.freq }
      assert_kind_of(Integer, CPU.freq)
   end

   def test_cpu_freq_expected_errors
      assert_raises(ArgumentError){ CPU.freq(0) }
   end

   def test_load_avg
      assert_respond_to(CPU, :load_avg)
      assert_nothing_raised{ CPU.load_avg }
      assert_kind_of(Array, CPU.load_avg)
      assert_equal(3,CPU.load_avg.length)
   end

   def test_load_avg_expected_errors
      assert_raises(ArgumentError){ CPU.load_avg(0) }
   end
   
   def test_machine
      assert_respond_to(CPU, :machine)
      assert_nothing_raised{ CPU.machine }
      assert_kind_of(String, CPU.machine)
   end

   def test_machine_expected_errors
      assert_raises(ArgumentError){ CPU.machine(0) }
   end

   def test_model
      assert_respond_to(CPU, :model)
      assert_nothing_raised{ CPU.model }
      assert_kind_of(String, CPU.model)
   end

   def test_model_expected_errors
      assert_raises(ArgumentError){ CPU.model(0) }
   end

   def test_num_cpu
      assert_respond_to(CPU, :num_cpu)
      assert_nothing_raised{ CPU.num_cpu }
      assert_kind_of(Integer, CPU.num_cpu)
   end

   def test_num_cpu_expected_errors
      assert_raises(ArgumentError){ CPU.num_cpu(0) }
   end
end
