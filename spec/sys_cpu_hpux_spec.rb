# frozen_string_literal: true

#####################################################################
# sys_cpu_hpux_spec.rb
#
# Test suite for the HP-UX platform. This should be run via the
# 'rake test' task.
#####################################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :hpux => true do
  example 'cpu_freq' do
    expect(described_class).to respond_to(:freq)
    expect{ described_class.freq }.not_to raise_error
    expect{ described_class.freq(0) }.not_to raise_error
    expect(described_class.freq).to be_kind_of(Integer)
  end

  example 'num_cpu' do
    expect(described_class).to respond_to(:num_cpu)
    expect{ described_class.num_cpu }.not_to raise_error
    expect(described_class.num_cpu).to be_kind_of(Integer)
  end

  example 'num_active_cpu' do
    expect(described_class).to respond_to(:num_active_cpu)
    expect{ described_class.num_active_cpu }.not_to raise_error
    expect(described_class.num_active_cpu).to be_kind_of(Integer)
  end

  example 'cpu_architecture' do
    expect(described_class).to respond_to(:architecture)
    expect{ described_class.architecture }.not_to raise_error
    expect(described_class.architecture).to be_kind_of(String)
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
    expect(described_class.load_avg).to be_kind_of(Array)
    expect(described_class.load_avg(0)).to be_kind_of(Array)
    expect(described_class.load_avg.length).to eq(3)
    expect(described_class.load_avg(0).length).to eq(3)
  end
end
