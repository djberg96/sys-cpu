#####################################################################
# sys_cpu_hpux_spec.rb
#
# Test suite for the HP-UX platform. This should be run via the
# 'rake test' task.
#####################################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :hpux => true do
  example "cpu_freq" do
    expect(Sys::CPU).to respond_to(:freq)
    expect{ Sys::CPU.freq }.not_to raise_error
    expect{ Sys::CPU.freq(0) }.not_to raise_error
    expect(Sys::CPU.freq).to be_kind_of(Integer)
  end

  example "num_cpu" do
    expect(Sys::CPU).to respond_to(:num_cpu)
    expect{ Sys::CPU.num_cpu }.not_to raise_error
    expect(Sys::CPU.num_cpu).to be_kind_of(Integer)
  end

  example "num_active_cpu" do
    expect(Sys::CPU).to respond_to(:num_active_cpu)
    expect{ Sys::CPU.num_active_cpu }.not_to raise_error
    expect(Sys::CPU.num_active_cpu).to be_kind_of(Integer)
  end

  example "cpu_architecture" do
    expect(Sys::CPU).to respond_to(:architecture)
    expect{ Sys::CPU.architecture }.not_to raise_error
    expect(Sys::CPU.architecture).to be_kind_of(String)
  end

  example "load_avg sanity check" do
    expect(Sys::CPU).to respond_to(:load_avg)
    expect{ Sys::CPU.load_avg }.not_to raise_error
    expect{ Sys::CPU.load_avg(0) }.not_to raise_error
    expect{ Sys::CPU.load_avg{ |e| }.not_to raise_error }
    expect{ Sys::CPU.load_avg(0){ }.to raise_error(ArgumentError) }
  end

  example "load_avg expected results" do
    expect(Sys::CPU.load_avg).to be_kind_of(Array)
    expect(Sys::CPU.load_avg(0)).to be_kind_of(Array)
    expect(Sys::CPU.load_avg.length).to eq(3)
    expect(Sys::CPU.load_avg(0).length).to eq(3)
  end
end
