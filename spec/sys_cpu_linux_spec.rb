# frozen_string_literal: true

###########################################################
# sys_cpu_linux_spec.rb
#
# Specs for sys-cpu for Linux. This should be run via
# the 'rake spec' task.
###########################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :linux do
  example 'dynamic methods are defined as expected' do
    expect do
      described_class.processors do |cs|
        cs.members.each{ |m| cs[m].to_s }
      end
    end.not_to raise_error
  end

  example 'load average works as expected' do
    expect{ described_class.load_avg }.not_to raise_error
    expect(described_class.load_avg.length).to eq(3)
  end

  example 'cpu_stats works as expected' do
    expect{ described_class.cpu_stats }.not_to raise_error
    expect(described_class.cpu_stats).to be_a(Hash)
    expect(described_class.cpu_stats['cpu0'].length).to be >= 4
  end

  example 'architecture works as expected' do
    expect{ described_class.architecture }.not_to raise_error
    expect(described_class.architecture).to be_a(String)
  end

  example 'model works as expected' do
    expect{ described_class.model }.not_to raise_error
    expect(described_class.model).to be_a(String)
  end

  example 'freq works as expected' do
    expect{ described_class.freq }.not_to raise_error
    expect(described_class.freq).to be_a(Numeric)
  end

  example 'num_cpu works as expected' do
    expect{ described_class.num_cpu }.not_to raise_error
    expect(described_class.num_cpu).to be_a(Numeric)
  end

  example 'bogus methods are not picked up by method_missing' do
    expect{ described_class.bogus }.to raise_error(NoMethodError)
  end

  example 'constructor is private' do
    expect{ described_class.new }.to raise_error(NoMethodError)
  end

  example 'info method returns comprehensive system information' do
    expect{ described_class.info }.not_to raise_error
    info = described_class.info
    expect(info).to be_a(Hash)

    # Basic CPU information should always be present
    expect(info).to have_key(:architecture)
    expect(info).to have_key(:num_cpu)
    expect(info).to have_key(:frequency_mhz)
    expect(info).to have_key(:load_avg)
    expect(info).to have_key(:cpu_stats)

    # Load avg should be an array of 3 floats
    expect(info[:load_avg]).to be_a(Array)
    expect(info[:load_avg].length).to eq(3)

    # CPU stats should be a hash
    expect(info[:cpu_stats]).to be_a(Hash)

    # Memory info should be present (if available)
    if info.key?(:memory_total)
      expect(info[:memory_total]).to be_a(Integer)
      expect(info[:memory_total]).to be > 0
    end
  end
end
