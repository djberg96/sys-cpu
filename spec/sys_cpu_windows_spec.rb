######################################################################
# sys_cpu_windows_spec.rb
#
# Test suite for MS Windows systems. This should be run via the
# 'rake test' task.
######################################################################
require 'spec_helper'
require 'sys/cpu'
require 'socket'

RSpec.describe Sys::CPU, :windows => true do
  let(:host) { Socket.gethostname }

  example "architecture" do
    expect(Sys::CPU).to respond_to(:architecture)
    expect{ Sys::CPU.architecture }.not_to raise_error
    expect{ Sys::CPU.architecture(host) }.not_to raise_error
    expect(Sys::CPU.architecture).to be_kind_of(String)
  end

  example "freq" do
    expect(Sys::CPU).to respond_to(:freq)
    expect{ Sys::CPU.freq }.not_to raise_error
    expect{ Sys::CPU.freq(0) }.not_to raise_error
    expect{ Sys::CPU.freq(0, host) }.not_to raise_error
    expect(Sys::CPU.freq).to be_kind_of(Integer)
  end

  example "model" do
    expect(Sys::CPU).to respond_to(:model)
    expect{ Sys::CPU.model }.not_to raise_error
    expect{ Sys::CPU.model(host) }.not_to raise_error
    expect(Sys::CPU.model).to be_kind_of(String)
  end

  example "num_cpu" do
    expect(Sys::CPU).to respond_to(:num_cpu)
    expect{ Sys::CPU.num_cpu }.not_to raise_error
    expect{ Sys::CPU.num_cpu(host) }.not_to raise_error
    expect(Sys::CPU.num_cpu).to be_kind_of(Integer)
  end

  example "cpu_type" do
    expect(Sys::CPU).to respond_to(:cpu_type)
    expect{ Sys::CPU.cpu_type }.not_to raise_error
    expect{ Sys::CPU.cpu_type(host) }.not_to raise_error
    expect(Sys::CPU.cpu_type).to be_kind_of(String)
  end

  example "load_avg" do
    expect(Sys::CPU).to respond_to(:load_avg)
    expect{ Sys::CPU.load_avg }.not_to raise_error
    expect{ Sys::CPU.load_avg(0, host) }.not_to raise_error
    expect(Sys::CPU.load_avg).to be_kind_of(Integer)
  end

  example "processors" do
    expect(Sys::CPU).to respond_to(:processors)
    expect{ Sys::CPU.processors{}.not_to raise_error }
  end
end
