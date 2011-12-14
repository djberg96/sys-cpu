######################################################################
# test_sys_cpu_windows.rb
#
# Test suite for MS Windows systems. This should be run via the
# 'rake test' task.
######################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'sys/cpu'
require 'test_sys_cpu_version'
require 'socket'
include Sys

class TC_Sys_CPU_Windows < Test::Unit::TestCase
  def self.startup
    @@host = Socket.gethostname
  end

  def test_architecture
    assert_respond_to(CPU, :architecture)
    assert_nothing_raised{ CPU.architecture }
    assert_nothing_raised{ CPU.architecture(@@host) }
    assert_kind_of(String, CPU.architecture, 'Invalid Type')
  end

  def test_freq
    assert_respond_to(CPU, :freq)
    assert_nothing_raised{ CPU.freq }
    assert_nothing_raised{ CPU.freq(0) }
    assert_nothing_raised{ CPU.freq(0, @@host) }
    assert_kind_of(Integer, CPU.freq, 'Invalid Type')
  end

  def test_model
    assert_respond_to(CPU, :model)
    assert_nothing_raised{ CPU.model }
    assert_nothing_raised{ CPU.model(@@host) }
    assert_kind_of(String, CPU.model, 'Invalid Type')
  end

  def test_num_cpu
    assert_respond_to(CPU, :num_cpu)
    assert_nothing_raised{ CPU.num_cpu }
    assert_nothing_raised{ CPU.num_cpu(@@host) }
    assert_kind_of(Integer, CPU.num_cpu, 'Invalid Type')
  end

  def test_cpu_type
    assert_respond_to(CPU, :cpu_type)
    assert_nothing_raised{ CPU.cpu_type }
    assert_nothing_raised{ CPU.cpu_type(@@host) }
    assert_kind_of(String, CPU.cpu_type, 'Invalid Type')
  end

  def test_load_avg
    assert_respond_to(CPU, :load_avg)
    assert_nothing_raised{ CPU.load_avg }
    assert_nothing_raised{ CPU.load_avg(0, @@host) }
    assert_kind_of(Integer, CPU.load_avg, 'Invalid Type')
  end

  def test_processors
    assert_respond_to(CPU, :processors)
    assert_nothing_raised{ CPU.processors{} }
  end

  def self.shutdown
    @@host = nil
  end
end
