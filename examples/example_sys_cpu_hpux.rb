#######################################################################
# example_sys_cpu_hpux.rb
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

puts "Num CPU: " + CPU.num_cpu.to_s
puts "Active CPU: " + CPU.num_active_cpu.to_s
puts "Architecture: " + CPU.architecture
puts "Speed/Freq: " + CPU.freq.to_s

puts "Load average for CPU 0: " + CPU.load_avg(0).join(", ")
puts "Overall Load Average: " + CPU.load_avg.join(", ")

puts "Individual Loads Averages:"
puts "=========================="
CPU.load_avg{ |e|
   p e
}
