###########################################################
# sys_cpu_sunos_spec.rb
#
# Test suite for sys-cpu on Solaris. This should be run
# via the 'rake spec' task.
###########################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :sunos => true do
  example "freq method basic functionality" do
    expect(Sys::CPU).to respond_to(:freq)
    expect{ Sys::CPU.freq }.not_to raise_error
  end

  example "freq method does not accept any arguments" do
    expect{ Sys::CPU.freq(0) }.to raise_error(ArgumentError)
  end

  example "freq method returns a sane value" do
    expect(Sys::CPU.freq).to be_kind_of(Integer)
    expect(Sys::CPU.freq).to be > 100
  end

  example "fpu_type basic functionality" do
    expect(Sys::CPU).to respond_to(:fpu_type)
    expect{ Sys::CPU.fpu_type }.not_to raise_error
  end

  example "fpu_type returns a sane value" do
    expect(Sys::CPU.fpu_type).to be_kind_of(String)
    expect(Sys::CPU.fpu_type).not_to be_empty
  end

  example "load_avg basic functionality" do
    expect(Sys::CPU).to respond_to(:load_avg)
    expect{ Sys::CPU.load_avg }.not_to raise_error
  end

  example "load_avg method returns the expected values" do
    expect(Sys::CPU.load_avg).to be_kind_of(Array)
    expect(Sys::CPU.load_avg.length).to eq(3)
    expect(Sys::CPU.load_avg.first).to be_kind_of(Float)
  end

  example "model method basic functionality" do
    expect(Sys::CPU).to respond_to(:model)
    expect{ Sys::CPU.model }.not_to raise_error
  end

  example "model method returns a sane value" do
    expect(Sys::CPU.model).to be_kind_of(String)
    expect(Sys::CPU.model).not_to be_empty
  end

  example "num_cpu method basic functionalty" do
    expect(Sys::CPU).to respond_to(:num_cpu)
    expect{ Sys::CPU.num_cpu }.not_to raise_error
  end

  example "num_cpu method returns a sane value" do
    expect(Sys::CPU.num_cpu).to be_kind_of(Integer)
    expect(Sys::CPU.num_cpu).to be > 0
  end

  example "state basic functionality" do
    expect(Sys::CPU).to respond_to(:state)
    expect{ Sys::CPU.state }.not_to raise_error
  end

  example "state method accepts one optional argument" do
    expect{ Sys::CPU.state(0) }.not_to raise_error
    expect{ Sys::CPU.state(0,0) }.to raise_error(ArgumentError)
  end

  example "state method returns a sane value" do
    expect(Sys::CPU.state(0)).to be_kind_of(String)
    expect(Sys::CPU.state.empty?).to be false
  end
end
