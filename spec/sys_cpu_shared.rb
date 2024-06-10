# frozen_string_literal: true

#######################################################################
# sys_cpu_spec.rb
#
# Only shared specs go here. Everything else goes into its own tagged
# spec file.
#######################################################################
require 'sys/cpu'
require 'rspec'

RSpec.shared_examples Sys::CPU do
  example 'version number is set to the expected value' do
    expect(Sys::CPU::VERSION).to eq('1.1.0')
  end

  example 'version number is frozen' do
    expect(Sys::CPU::VERSION).to be_frozen
  end

  example 'constructor is private' do
    expect{ described_class.new }.to raise_error(NoMethodError)
  end
end
