###########################################################
# test_sys_cpu_sunos.rb
#
# Test suite for sys-cpu on Solaris. This should be run
# via the 'rake test' task.
###########################################################
require 'sys/cpu'
require 'test-unit'
include Sys

class TC_Sys_CPU_SunOS < Test::Unit::TestCase
  test "freq method basic functionality" do
    assert_respond_to(CPU, :freq)
    assert_nothing_raised{ CPU.freq }
  end

  test "freq method does not accept any arguments" do
    assert_raise(ArgumentError){ CPU.freq(0) }
  end

  test "freq method returns a sane value" do
    assert_kind_of(Integer, CPU.freq)
    assert_true(CPU.freq > 100)
  end

  test "fpu_type basic functionality" do
    assert_respond_to(CPU, :fpu_type)
    assert_nothing_raised{ CPU.fpu_type }
  end

  test "fpu_type returns a sane value" do
    assert_kind_of(String, CPU.fpu_type)
    assert_false(CPU.fpu_type.empty?)
  end

  test "load_avg basic functionality" do
    assert_respond_to(CPU, :load_avg)
    assert_nothing_raised{ CPU.load_avg }
  end

  test "load_avg method returns the expected values" do
    assert_kind_of(Array, CPU.load_avg)
    assert_equal(3, CPU.load_avg.length)
    assert_kind_of(Float, CPU.load_avg.first)
  end

  test "model method basic functionality" do
    assert_respond_to(CPU, :model)
    assert_nothing_raised{ CPU.model }
  end

  test "model method returns a sane value" do
    assert_kind_of(String, CPU.model)
    assert_false(CPU.model.empty?)
  end

  test "num_cpu method basic functionalty" do
    assert_respond_to(CPU, :num_cpu)
    assert_nothing_raised{ CPU.num_cpu }
  end

  test "num_cpu method returns a sane value" do
    assert_kind_of(Integer, CPU.num_cpu)
    assert_true(CPU.num_cpu > 0)
  end

  test "state basic functionality" do
    assert_respond_to(CPU, :state)
    assert_nothing_raised{ CPU.state }
  end

  test "state method accepts one optional argument" do
    assert_nothing_raised{ CPU.state(0) }
    assert_raise(ArgumentError){ CPU.state(0,0) }
  end

  test "state method returns a sane value" do
    assert_kind_of(String, CPU.state(0))
    assert_false(CPU.state.empty?)
  end
end
