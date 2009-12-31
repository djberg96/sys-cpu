#######################################################################
# example_sys_cpu_linux.rb
#
# Sample cript for general futzing. You can run this code via the
# 'rake example' task.
#
# Modify as you see fit.
#######################################################################
require "sys/cpu"
require "pp"
include Sys

puts "VERSION: " + CPU::VERSION
puts "========"

puts "Load Average: " + CPU.load_avg.join(", ")

puts "Processor Info:"
puts "==============="
pp CPU.processors

puts "CPU STATS:"
puts "=========:"

pp CPU.cpu_stats
