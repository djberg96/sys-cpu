#!/usr/bin/env ruby
# frozen_string_literal: true

# Example usage of Sys::CPU.info method on macOS (Darwin)
# This demonstrates the comprehensive CPU information collection

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'sys/cpu'

puts "=== Comprehensive CPU Information (macOS) ==="
puts

begin
  info = Sys::CPU.info

  puts "Basic Information:"
  puts "  Architecture: #{info[:architecture]}"
  puts "  Machine: #{info[:machine]}"
  puts "  Model: #{info[:model]}"
  puts "  Brand String: #{info[:brand_string]}"
  puts "  OS Type: #{info[:os_type]}"
  puts "  OS Release: #{info[:os_release]}"
  puts

  puts "CPU Topology:"
  puts "  Total CPUs: #{info[:num_cpu]}"
  puts "  Logical CPUs: #{info[:logical_cpu]}"
  puts "  Physical CPUs: #{info[:physical_cpu]}"
  puts "  Active CPUs: #{info[:active_cpu]}"
  puts "  Cores per Package: #{info[:cores_per_package]}"
  puts "  Thread Count: #{info[:thread_count]}"
  puts

  if info[:performance_levels]
    puts "Performance Levels (Apple Silicon):"
    info[:performance_levels].each do |level, data|
      puts "  Level #{level}:"
      puts "    Physical CPUs: #{data[:physical_cpu]} (max: #{data[:physical_cpu_max]})"
      puts "    Logical CPUs: #{data[:logical_cpu]} (max: #{data[:logical_cpu_max]})"
      puts "    CPUs per L2: #{data[:cpus_per_l2]}"
    end
    puts
  end

  puts "Performance:"
  puts "  Frequency: #{info[:frequency_mhz]} MHz"
  puts "  Timebase Frequency: #{info[:timebase_frequency]} Hz" if info[:timebase_frequency]
  puts "  CPU Type: #{info[:cpu_type]}" if info[:cpu_type]
  puts "  CPU Subtype: #{info[:cpu_subtype]}" if info[:cpu_subtype]
  puts "  Load Average (1m, 5m, 15m): #{info[:load_avg].map { |x| '%.2f' % x }.join(', ')}"
  puts

  if info[:cache]
    puts "Cache Information:"
    cache = info[:cache]
    puts "  L1 Instruction: #{cache[:l1_instruction_size]} bytes" if cache[:l1_instruction_size]
    puts "  L1 Data: #{cache[:l1_data_size]} bytes" if cache[:l1_data_size]
    puts "  L2: #{cache[:l2_size]} bytes" if cache[:l2_size]
    puts "  L3: #{cache[:l3_size]} bytes" if cache[:l3_size]
    puts "  Cache Line Size: #{cache[:line_size]} bytes" if cache[:line_size]

    if cache[:config]
      puts "  Cache Configuration:"
      cache[:config].each { |k, v| puts "    #{k}: #{v}" }
    end

    if cache[:sizes]
      puts "  Cache Sizes:"
      cache[:sizes].each { |k, v| puts "    #{k}: #{v} bytes" }
    end
    puts
  end

  puts "Memory Information:"
  puts "  Total Memory: #{info[:memory_size]} bytes (#{(info[:memory_size] / 1024.0**3).round(2)} GB)" if info[:memory_size]
  puts "  Usable Memory: #{info[:memory_usable]} bytes (#{(info[:memory_usable] / 1024.0**3).round(2)} GB)" if info[:memory_usable]
  puts "  Page Size: #{info[:page_size]} bytes" if info[:page_size]
  puts "  Page Size (32-bit): #{info[:page_size_32]} bytes" if info[:page_size_32]
  puts "  Byte Order: #{info[:byte_order]}" if info[:byte_order]
  puts

  if info[:features]
    puts "CPU Features and Capabilities:"
    features = info[:features]

    # Group features for better readability
    arm_features = features.select { |k, v| k.to_s.start_with?('arm_') && v }
    general_features = features.select { |k, v| !k.to_s.start_with?('arm_') && !k.to_s.start_with?('feat_') && k != :feat_flags && k != :arm_caps && k != :sme_max_svl_b && v }

    if !arm_features.empty?
      puts "  ARM Features:"
      arm_features.each { |k, v| puts "    #{k}: #{v}" }
    end

    if !general_features.empty?
      puts "  General Features:"
      general_features.each { |k, v| puts "    #{k}: #{v}" }
    end

    if features[:feat_flags]
      enabled_feat = features[:feat_flags].select { |k, v| v }.keys
      puts "  Enabled FEAT_ Flags: #{enabled_feat.join(', ')}" unless enabled_feat.empty?
    end

    puts "  ARM Capability Bits: #{features[:arm_caps]}" if features[:arm_caps]
    puts "  SME Max SVL: #{features[:sme_max_svl_b]} bytes" if features[:sme_max_svl_b]
  end

rescue Sys::CPU::Error => e
  puts "Error: #{e.message}"
rescue => e
  puts "Unexpected error: #{e.message}"
end
