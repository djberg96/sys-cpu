#######################################################################
# example_sys_cpu_bsd.rb
#
# Sample cript for general futzing. You can run this code via the
# 'rake example' task.
#
# Modify as you see fit.
#######################################################################
require "sys/cpu"
include Sys

puts "VERSION: " + CPU::VERSION

puts "Load Average: " + CPU.load_avg.join(", ")
puts "CPU Freq (speed): " + CPU.freq.to_s unless RUBY_PLATFORM.match('darwin')
puts "Num CPU: " + CPU.num_cpu.to_s
puts "Architecture: " + CPU.architecture
puts "Machine: " + CPU.machine
puts "Model: " + CPU.model
