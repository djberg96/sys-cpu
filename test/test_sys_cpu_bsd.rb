#############################################################
# test_sys_cpu_bsd.rb
#
# The test case for sys-cpu on BSD flavors, including OS X.
#############################################################
require 'sys/cpu'
require 'rbconfig'
require 'test-unit'
require 'test_sys_cpu_version'
include Sys

class TC_Sys_CPU_BSD < Test::Unit::TestCase
  test "architecture method basic functionality" do
    assert_respond_to(CPU, :architecture)
    assert_nothing_raised{ CPU.architecture }
  end

  test "architecture method returns a sane value" do
    assert_kind_of(String, CPU.architecture)
    assert_true(CPU.architecture.size > 0)
  end

  test "architecture method does not accept any arguments" do
    assert_raises(ArgumentError){ CPU.architecture(0) }
  end

  test "freq method basic functionality" do
    assert_respond_to(CPU, :freq)
    assert_nothing_raised{ CPU.freq }
  end

  test "freq method returns expected value" do
    assert_kind_of(Integer, CPU.freq)
    assert_true(CPU.freq > 0)
  end

  test "freq method does not accept any arguments" do
    assert_raises(ArgumentError){ CPU.freq(0) }
  end

  test "load_avg method basic functionality" do
    assert_respond_to(CPU, :load_avg)
    assert_nothing_raised{ CPU.load_avg }
  end

  test "load_avg returns the expected results" do
    assert_kind_of(Array, CPU.load_avg)
    assert_equal(3, CPU.load_avg.length)
    assert_kind_of(Float, CPU.load_avg[0])
  end

  test "load_avg does not accept any arguments" do
    assert_raises(ArgumentError){ CPU.load_avg(0) }
  end

  test "machine method basic functionality" do
    assert_respond_to(CPU, :machine)
    assert_nothing_raised{ CPU.machine }
  end

  test "machine method returns sane value" do
    assert_kind_of(String, CPU.machine)
    assert_true(CPU.machine.size > 0)
  end

  test "machine method does not accept any arguments" do
    assert_raises(ArgumentError){ CPU.machine(0) }
  end

  test "model method basic functionality" do
    assert_respond_to(CPU, :model)
    assert_nothing_raised{ CPU.model }
  end

  test "model method returns sane value" do
    assert_kind_of(String, CPU.model)
    assert_true(CPU.model.length > 0)
  end

  test "model method does not accept any arguments" do
    assert_raises(ArgumentError){ CPU.model(0) }
  end

  test "num_cpu method basic functionality" do
    assert_respond_to(CPU, :num_cpu)
    assert_nothing_raised{ CPU.num_cpu }
  end

  test "num_cpu method returns expected value" do
    assert_kind_of(Integer, CPU.num_cpu)
    assert_true(CPU.num_cpu > 0)
  end

  test "num_cpu method does not accept any arguments" do
    assert_raises(ArgumentError){ CPU.num_cpu(0) }
  end
end
