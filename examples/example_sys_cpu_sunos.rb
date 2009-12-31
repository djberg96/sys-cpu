#######################################################################
# example_sys_cpu_sunos.rb
#
# Sample cript for general futzing. You can run this code via the
# 'rake example' task.
#
# Modify as you see fit.
#######################################################################
require "sys/cpu"
include Sys

puts "VERSION: " + CPU::VERSION
puts "========"

puts "Load Average: " + CPU.load_avg.join(", ")
puts "CPU Freq (speed): " + CPU.freq.to_s
puts "CPU State: " + CPU.state(0)
puts "Num CPU: " + CPU.num_cpu.to_s
puts "Type: " + CPU.cpu_type
puts "FPU Type: " + CPU.fpu_type
puts "Model: " + CPU.model
