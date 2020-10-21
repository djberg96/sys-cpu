#############################################################
# test_sys_cpu_bsd.rb
#
# The test case for sys-cpu on BSD flavors, including OS X.
#############################################################
require 'sys/cpu'
require 'rbconfig'
require 'spec_helper'
include Sys

RSpec.describe Sys::CPU, :bsd => true do
  example "architecture method basic functionality" do
    expect(CPU).to respond_to(:architecture)
    expect{ CPU.architecture }.not_to raise_error
  end

  example "architecture method returns a sane value" do
    expect(CPU.architecture).to be_kind_of(String)
    expect(CPU.architecture.size).to be > 0
  end

  example "architecture method does not accept any arguments" do
    expect{ CPU.architecture(0) }.to raise_error(ArgumentError)
  end

  example "freq method basic functionality" do
    expect(CPU).to respond_to(:freq)
    expect{ CPU.freq }.not_to raise_error
  end

  example "freq method returns expected value" do
    expect( CPU.freq).to be_kind_of(Integer)
    expect(CPU.freq).to be > 0
  end

  example "freq method does not accept any arguments" do
    expect{ CPU.freq(0) }.to raise_error(ArgumentError)
  end

  example "load_avg method basic functionality" do
    expect(CPU).to respond_to(:load_avg)
    expect{ CPU.load_avg }.not_to raise_error
  end

  example "load_avg returns the expected results" do
    expect(CPU.load_avg).to be_kind_of(Array)
    expect(CPU.load_avg.length).to eq(3)
    expect(CPU.load_avg[0]).to be_kind_of(Float)
  end

  example "load_avg does not accept any arguments" do
    expect{ CPU.load_avg(0) }.to raise_error(ArgumentError)
  end

  example "machine method basic functionality" do
    expect(CPU).to respond_to(:machine)
    expect{ CPU.machine }.not_to raise_error
  end

  example "machine method returns sane value" do
    expect(CPU.machine).to be_kind_of(String)
    expect(CPU.machine.size).to be > 0
  end

  example "machine method does not accept any arguments" do
    expect{ CPU.machine(0) }.to raise_error(ArgumentError)
  end

  example "model method basic functionality" do
    expect(CPU).to respond_to(:model)
    expect{ CPU.model }.not_to raise_error
  end

  example "model method returns sane value" do
    expect( CPU.model).to be_kind_of(String)
    expect(CPU.model.length).to be > 0
  end

  example "model method does not accept any arguments" do
    expect{ CPU.model(0) }.to raise_error(ArgumentError)
  end

  example "num_cpu method basic functionality" do
    expect(CPU).to respond_to(:num_cpu)
    expect{ CPU.num_cpu }.not_to raise_error
  end

  example "num_cpu method returns expected value" do
    expect( CPU.num_cpu).to be_kind_of(Integer)
    expect(CPU.num_cpu).to be > 0
  end

  example "num_cpu method does not accept any arguments" do
    expect{ CPU.num_cpu(0) }.to raise_error(ArgumentError)
  end
end
