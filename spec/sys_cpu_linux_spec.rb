# frozen_string_literal: true

###########################################################
# sys_cpu_linux_spec.rb
#
# Specs for sys-cpu for Linux. This should be run via
# the 'rake spec' task.
###########################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :linux => true do
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
    expect(described_class.cpu_stats).to be_kind_of(Hash)
    expect(described_class.cpu_stats['cpu0'].length).to be >= 4
  end

  example 'architecture works as expected' do
    expect{ described_class.architecture }.not_to raise_error
    expect(described_class.architecture).to be_kind_of(String)
  end

  example 'model works as expected' do
    expect{ described_class.model }.not_to raise_error
    expect(described_class.model).to be_kind_of(String)
  end

  example 'freq works as expected' do
    expect{ described_class.freq }.not_to raise_error
    expect(described_class.freq).to be_kind_of(Numeric)
  end

  example 'num_cpu works as expected' do
    expect{ described_class.num_cpu }.not_to raise_error
    expect(described_class.num_cpu).to be_kind_of(Numeric)
  end

  example 'bogus methods are not picked up by method_missing' do
    expect{ described_class.bogus }.to raise_error(NoMethodError)
  end

  example 'constructor is private' do
    expect{ described_class.new }.to raise_error(NoMethodError)
  end
end
