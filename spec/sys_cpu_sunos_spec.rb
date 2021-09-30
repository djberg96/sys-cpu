# frozen_string_literal: true

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
    expect(described_class).to respond_to(:freq)
    expect{ described_class.freq }.not_to raise_error
  end

  example "freq method does not accept any arguments" do
    expect{ described_class.freq(0) }.to raise_error(ArgumentError)
  end

  example "freq method returns a sane value" do
    expect(described_class.freq).to be_kind_of(Integer)
    expect(described_class.freq).to be > 100
  end

  example "fpu_type basic functionality" do
    expect(described_class).to respond_to(:fpu_type)
    expect{ described_class.fpu_type }.not_to raise_error
  end

  example "fpu_type returns a sane value" do
    expect(described_class.fpu_type).to be_kind_of(String)
    expect(described_class.fpu_type).not_to be_empty
  end

  example "load_avg basic functionality" do
    expect(described_class).to respond_to(:load_avg)
    expect{ described_class.load_avg }.not_to raise_error
  end

  example "load_avg method returns the expected values" do
    expect(described_class.load_avg).to be_kind_of(Array)
    expect(described_class.load_avg.length).to eq(3)
    expect(described_class.load_avg.first).to be_kind_of(Float)
  end

  example "model method basic functionality" do
    expect(described_class).to respond_to(:model)
    expect{ described_class.model }.not_to raise_error
  end

  example "model method returns a sane value" do
    expect(described_class.model).to be_kind_of(String)
    expect(described_class.model).not_to be_empty
  end

  example "num_cpu method basic functionalty" do
    expect(described_class).to respond_to(:num_cpu)
    expect{ described_class.num_cpu }.not_to raise_error
  end

  example "num_cpu method returns a sane value" do
    expect(described_class.num_cpu).to be_kind_of(Integer)
    expect(described_class.num_cpu).to be > 0
  end

  example "state basic functionality" do
    expect(described_class).to respond_to(:state)
    expect{ described_class.state }.not_to raise_error
  end

  example "state method accepts one optional argument" do
    expect{ described_class.state(0) }.not_to raise_error
    expect{ described_class.state(0, 0) }.to raise_error(ArgumentError)
  end

  example "state method returns a sane value" do
    expect(described_class.state(0)).to be_kind_of(String)
    expect(described_class.state.empty?).to be false
  end
end
