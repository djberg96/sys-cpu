# frozen_string_literal: true

######################################################################
# sys_cpu_windows_spec.rb
#
# Test suite for MS Windows systems. This should be run via the
# 'rake test' task.
######################################################################
require 'spec_helper'
require 'sys/cpu'
require 'socket'

RSpec.describe Sys::CPU, :windows do
  let(:host) { Socket.gethostname }

  example 'architecture' do
    expect(described_class).to respond_to(:architecture)
    expect{ described_class.architecture }.not_to raise_error
    expect{ described_class.architecture(host) }.not_to raise_error
    expect(described_class.architecture).to be_a(String)
  end

  example 'freq basic functionality' do
    expect(described_class).to respond_to(:freq)
    expect{ described_class.freq }.not_to raise_error
    expect(described_class.freq).to be_a(Integer)
  end

  example 'freq with arguments' do
    expect{ described_class.freq(0) }.not_to raise_error
    expect{ described_class.freq(0, host) }.not_to raise_error
  end

  example 'model' do
    expect(described_class).to respond_to(:model)
    expect{ described_class.model }.not_to raise_error
    expect{ described_class.model(host) }.not_to raise_error
    expect(described_class.model).to be_a(String)
  end

  example 'num_cpu' do
    expect(described_class).to respond_to(:num_cpu)
    expect{ described_class.num_cpu }.not_to raise_error
    expect{ described_class.num_cpu(host) }.not_to raise_error
    expect(described_class.num_cpu).to be_a(Integer)
  end

  example 'cpu_type' do
    expect(described_class).to respond_to(:cpu_type)
    expect{ described_class.cpu_type }.not_to raise_error
    expect{ described_class.cpu_type(host) }.not_to raise_error
    expect(described_class.cpu_type).to be_a(String)
  end

  example 'load_avg' do
    expect(described_class).to respond_to(:load_avg)
    expect{ described_class.load_avg }.not_to raise_error
    expect{ described_class.load_avg(0, host) }.not_to raise_error
    expect(described_class.load_avg).to be_a(Integer).or be_a(NilClass)
  end

  example 'cpu_usage works as expected' do
    expect(described_class).to respond_to(:cpu_usage)
    expect{ described_class.cpu_usage }.not_to raise_error
    expect{ described_class.cpu_usage(sample_time: 0.1, samples: 0, host: host) }.not_to raise_error
    expect(described_class.cpu_usage).to be_a(Numeric).or be_a(NilClass)
  end

  example 'cpu_usage sampling produces a valid range' do
    # Sampled usage should be a number between 0 and 100.
    result = described_class.cpu_usage(sample_time: 0.1)
    expect(result).to be_a(Numeric).or be_nil
    expect(result).to be >= 0 if result
    expect(result).to be <= 100 if result
  end

  example 'processors' do
    expect(described_class).to respond_to(:processors)
    expect{ described_class.processors{} }.not_to raise_error
  end
end
