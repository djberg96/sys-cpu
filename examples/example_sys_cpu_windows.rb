#######################################################################
# example_sys_cpu_windows.rb
#
# Sample cript for general futzing. You can run this code via the
# 'rake example' task.
#
# Modify as you see fit.
#######################################################################
require 'sys/cpu'
require 'pp'
include Sys

puts "VERSION: " + CPU::VERSION
puts "========"

puts "Architecture: " + CPU.architecture.to_s
puts "CPU Speed (Frequency): " + CPU.freq.to_s
puts "Load Average: " + CPU.load_avg.to_s
puts "Model: " + CPU.model.to_s
puts "Type: " + CPU.cpu_type.to_s
puts "Num CPU: " + CPU.num_cpu.to_s

CPU.processors{ |cpu|
   pp cpu
}
