#######################################################################
# sys_cpu_version_spec.rb
#
# The sole purpose of this test case is to verify the version number.
# This reduces the pain of having separate tests for the VERSION
# constant in every single test case.
#######################################################################
require 'sys/cpu'
require 'rspec'

RSpec.describe Sys::CPU::VERSION do
  example "version number is set to the expected value" do
    expect(Sys::CPU::VERSION).to eq('1.0.0')
  end

  example "version number is frozen" do
    expect(Sys::CPU::VERSION).to be_frozen?
  end
end
