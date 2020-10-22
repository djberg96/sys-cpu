###########################################################
# sys_cpu_linux_spec.rb
#
# Specs for sys-cpu for Linux. This should be run via
# the 'rake spec' task.
###########################################################
require 'sys/cpu'
require 'spec_helper'

RSpec.describe Sys::CPU, :linux => true do
  example "dynamic methods are defined as expected" do
    expect{
      Sys::CPU.processors{ |cs|
        cs.members.each{ |m| cs[m].to_s }
      }
    }.not_to raise_error
  end

  example "load average works as expected" do
    expect{ Sys::CPU.load_avg }.not_to raise_error
    expect(Sys::CPU.load_avg.length).to eq(3)
  end

  example "cpu_stats works as expected" do
    expect{ Sys::CPU.cpu_stats }.not_to raise_error
    expect(Sys::CPU.cpu_stats).to be_kind_of(Hash)
    expect(Sys::CPU.cpu_stats['cpu0'].length).to be >= 4
  end

  example "architecture works as expected" do
    expect{ Sys::CPU.architecture }.not_to raise_error
    expect(Sys::CPU.architecture).to be_kind_of(String)
  end

  example "model works as expected" do
    expect{ Sys::CPU.model }.not_to raise_error
    expect(Sys::CPU.model).to be_kind_of(String)
  end

  example "freq works as expected" do
    expect{ Sys::CPU.freq }.not_to raise_error
    expect(Sys::CPU.freq).to be_kind_of(Numeric)
  end

  example "num_cpu works as expected" do
    expect{ Sys::CPU.num_cpu }.not_to raise_error
    expect(Sys::CPU.num_cpu).to be_kind_of(Numeric)
  end

  example "bogus methods are not picked up by method_missing" do
    expect{Sys::CPU.bogus }.to raise_error(NoMethodError)
  end
end
