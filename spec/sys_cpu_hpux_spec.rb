# frozen_string_literal: true

#####################################################################
# sys_cpu_hpux_spec.rb
#
# Test suite for the HP-UX platform. This should be run via the
# 'rake test' task.
#####################################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :hpux do
  example 'cpu_freq' do
    expect(described_class).to respond_to(:freq)
    expect{ described_class.freq }.not_to raise_error
    expect{ described_class.freq(0) }.not_to raise_error
    expect(described_class.freq).to be_a(Integer)
  end

  example 'num_cpu' do
    expect(described_class).to respond_to(:num_cpu)
    expect{ described_class.num_cpu }.not_to raise_error
    expect(described_class.num_cpu).to be_a(Integer)
  end

  example 'num_active_cpu' do
    expect(described_class).to respond_to(:num_active_cpu)
    expect{ described_class.num_active_cpu }.not_to raise_error
    expect(described_class.num_active_cpu).to be_a(Integer)
  end

  example 'cpu_architecture' do
    expect(described_class).to respond_to(:architecture)
    expect{ described_class.architecture }.not_to raise_error
    expect(described_class.architecture).to be_a(String)
  end

  example 'load_avg basic sanity check' do
    expect(described_class).to respond_to(:load_avg)
    expect{ described_class.load_avg }.not_to raise_error
  end

  example 'load_avg with arguments and/or block sanity check' do
    expect{ described_class.load_avg(0) }.not_to raise_error
    expect{ described_class.load_avg{} }.not_to raise_error
    expect{ described_class.load_avg(0){} }.to raise_error(ArgumentError)
  end

  example 'load_avg expected results' do
    expect(described_class.load_avg).to be_a(Array)
    expect(described_class.load_avg(0)).to be_a(Array)
    expect(described_class.load_avg.length).to eq(3)
    expect(described_class.load_avg(0).length).to eq(3)
  end

  example 'cpu_usage works as expected' do
    expect(described_class).to respond_to(:cpu_usage)
    expect{ described_class.cpu_usage }.not_to raise_error
    expect{ described_class.cpu_usage(sample_time: 0.1) }.not_to raise_error
    expect(described_class.cpu_usage).to be_a(Numeric).or be_nil
  end

  example 'cpu_usage sampling produces a valid range' do
    result = described_class.cpu_usage(sample_time: 0.1)
    expect(result).to be_a(Numeric).or be_nil
    expect(result).to be >= 0 if result
    expect(result).to be <= 100 if result
  end
end
