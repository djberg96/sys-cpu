#############################################################
# test_sys_cpu_bsd.rb
#
# The test case for sys-cpu on BSD flavors, including OS X.
#############################################################
require 'sys/cpu'
require 'rbconfig'
require 'spec_helper'

RSpec.describe Sys::CPU, :bsd => true do
  example "architecture method basic functionality" do
    expect(Sys::CPU).to respond_to(:architecture)
    expect{ Sys::CPU.architecture }.not_to raise_error
  end

  example "architecture method returns a sane value" do
    expect(Sys::CPU.architecture).to be_kind_of(String)
    expect(Sys::CPU.architecture.size).to be > 0
  end

  example "architecture method does not accept any arguments" do
    expect{ Sys::CPU.architecture(0) }.to raise_error(ArgumentError)
  end

  example "freq method basic functionality" do
    expect(Sys::CPU).to respond_to(:freq)
    expect{ Sys::CPU.freq }.not_to raise_error
  end

  example "freq method returns expected value" do
    expect(Sys::CPU.freq).to be_kind_of(Integer)
    expect(Sys::CPU.freq).to be > 0
  end

  example "freq method does not accept any arguments" do
    expect{ Sys::CPU.freq(0) }.to raise_error(ArgumentError)
  end

  example "load_avg method basic functionality" do
    expect(Sys::CPU).to respond_to(:load_avg)
    expect{ Sys::CPU.load_avg }.not_to raise_error
  end

  example "load_avg returns the expected results" do
    expect(Sys::CPU.load_avg).to be_kind_of(Array)
    expect(Sys::CPU.load_avg.length).to eq(3)
    expect(Sys::CPU.load_avg[0]).to be_kind_of(Float)
  end

  example "load_avg does not accept any arguments" do
    expect{ Sys::CPU.load_avg(0) }.to raise_error(ArgumentError)
  end

  example "machine method basic functionality" do
    expect(Sys::CPU).to respond_to(:machine)
    expect{ Sys::CPU.machine }.not_to raise_error
  end

  example "machine method returns sane value" do
    expect(Sys::CPU.machine).to be_kind_of(String)
    expect(Sys::CPU.machine.size).to be > 0
  end

  example "machine method does not accept any arguments" do
    expect{ Sys::CPU.machine(0) }.to raise_error(ArgumentError)
  end

  example "model method basic functionality" do
    expect(Sys::CPU).to respond_to(:model)
    expect{ Sys::CPU.model }.not_to raise_error
  end

  example "model method returns sane value" do
    expect(Sys::CPU.model).to be_kind_of(String)
    expect(Sys::CPU.model.length).to be > 0
  end

  example "model method does not accept any arguments" do
    expect{ Sys::CPU.model(0) }.to raise_error(ArgumentError)
  end

  example "num_cpu method basic functionality" do
    expect(Sys::CPU).to respond_to(:num_cpu)
    expect{ Sys::CPU.num_cpu }.not_to raise_error
  end

  example "num_cpu method returns expected value" do
    expect(Sys::CPU.num_cpu).to be_kind_of(Integer)
    expect(Sys::CPU.num_cpu).to be > 0
  end

  example "num_cpu method does not accept any arguments" do
    expect{ Sys::CPU.num_cpu(0) }.to raise_error(ArgumentError)
  end
end
