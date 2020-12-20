#######################################################################
# sys_cpu_spec.rb
#
# Only shared specs go here. Everything else goes into its own tagged
# spec file.
#######################################################################
require 'sys/cpu'
require 'rspec'

RSpec.describe Sys::CPU::VERSION do
  example "version number is set to the expected value" do
    expect(Sys::CPU::VERSION).to eq('1.0.1')
  end

  example "version number is frozen" do
    expect(Sys::CPU::VERSION).to be_frozen
  end
end
