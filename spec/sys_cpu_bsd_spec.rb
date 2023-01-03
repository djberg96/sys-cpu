# frozen_string_literal: true

#############################################################
# sys_cpu_bsd_spec.rb
#
# Specs for sys-cpu on BSD flavors, including OS X.
#############################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :bsd => true do
  example 'architecture method basic functionality' do
    expect(described_class).to respond_to(:architecture)
    expect{ described_class.architecture }.not_to raise_error
  end

  example 'architecture method returns a sane value' do
    expect(described_class.architecture).to be_kind_of(String)
    expect(described_class.architecture.size).to be > 0
  end

  example 'architecture method does not accept any arguments' do
    expect{ described_class.architecture(0) }.to raise_error(ArgumentError)
  end

  example 'freq method basic functionality' do
    expect(described_class).to respond_to(:freq)
    expect{ described_class.freq }.not_to raise_error
  end

  example 'freq method returns expected value' do
    expect(described_class.freq).to be_kind_of(Integer)
    expect(described_class.freq).to be > 0
  end

  example 'freq method does not accept any arguments' do
    expect{ described_class.freq(0) }.to raise_error(ArgumentError)
  end

  example 'load_avg method basic functionality' do
    expect(described_class).to respond_to(:load_avg)
    expect{ described_class.load_avg }.not_to raise_error
  end

  example 'load_avg returns the expected results' do
    expect(described_class.load_avg).to be_kind_of(Array)
    expect(described_class.load_avg.length).to eq(3)
    expect(described_class.load_avg[0]).to be_kind_of(Float)
  end

  example 'load_avg does not accept any arguments' do
    expect{ described_class.load_avg(0) }.to raise_error(ArgumentError)
  end

  example 'machine method basic functionality' do
    expect(described_class).to respond_to(:machine)
    expect{ described_class.machine }.not_to raise_error
  end

  example 'machine method returns sane value' do
    expect(described_class.machine).to be_kind_of(String)
    expect(described_class.machine.size).to be > 0
  end

  example 'machine method does not accept any arguments' do
    expect{ described_class.machine(0) }.to raise_error(ArgumentError)
  end

  example 'model method basic functionality' do
    expect(described_class).to respond_to(:model)
    expect{ described_class.model }.not_to raise_error
  end

  example 'model method returns sane value' do
    expect(described_class.model).to be_kind_of(String)
    expect(described_class.model.length).to be > 0
  end

  example 'model method does not accept any arguments' do
    expect{ described_class.model(0) }.to raise_error(ArgumentError)
  end

  example 'num_cpu method basic functionality' do
    expect(described_class).to respond_to(:num_cpu)
    expect{ described_class.num_cpu }.not_to raise_error
  end

  example 'num_cpu method returns expected value' do
    expect(described_class.num_cpu).to be_kind_of(Integer)
    expect(described_class.num_cpu).to be > 0
  end

  example 'num_cpu method does not accept any arguments' do
    expect{ described_class.num_cpu(0) }.to raise_error(ArgumentError)
  end

  context "ffi methods and constants are private" do
    example "ffi constants are private" do
      constants = described_class.constants
      expect(constants).not_to include(:CTL_HW)
      expect(constants).not_to include(:CPU_TYPE_X86)
      expect(constants).not_to include(:CPU_TYPE_X86_64)
      expect(constants).not_to include(:HW_MACHINE)
      expect(constants).not_to include(:ClockInfo)
    end

    example "ffi core methods are private" do
      methods = described_class.methods(false)
      expect(methods).not_to include(:attach_function)
      expect(methods).not_to include(:bitmask)
    end

    example "ffi attached methods are private" do
      methods = described_class.methods(false)
      expect(methods).not_to include(:sysctl)
      expect(methods).not_to include(:sysctlbyname)
    end
  end
end
