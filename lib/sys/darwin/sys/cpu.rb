# frozen_string_literal: true

require 'ffi'
require 'rbconfig'

# The Sys module serves as a namespace only.
module Sys
  # The CPU class encapsulates information about the physical cpu's on your system.
  class CPU
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # Error raised if any of the CPU methods fail.
    class Error < StandardError; end

    CTL_HW = 6 # Generic hardware/cpu

    private_constant :CTL_HW

    HW_MACHINE      = 1  # Machine class
    HW_MODEL        = 2  # Specific machine model
    HW_NCPU         = 3  # Number of CPU's
    HW_CPU_FREQ     = 15 # CPU frequency
    HW_MACHINE_ARCH = 12 # Machine architecture

    private_constant :HW_MACHINE, :HW_MODEL, :HW_NCPU, :HW_CPU_FREQ, :HW_MACHINE_ARCH

    SI_MACHINE          = 5
    SI_ARCHITECTURE     = 6
    SC_NPROCESSORS_ONLN = 15

    private_constant :SI_MACHINE, :SI_ARCHITECTURE, :SC_NPROCESSORS_ONLN

    P_OFFLINE  = 1
    P_ONLINE   = 2
    P_FAULTED  = 4
    P_POWEROFF = 5
    P_NOINTR   = 6
    P_SPARE    = 7

    private_constant :P_OFFLINE, :P_ONLINE, :P_FAULTED, :P_POWEROFF, :P_NOINTR, :P_SPARE

    CPU_ARCH_ABI64     = 0x01000000
    CPU_TYPE_X86       = 7
    CPU_TYPE_X86_64    = (CPU_TYPE_X86 | CPU_ARCH_ABI64)
    CPU_TYPE_ARM       = 12
    CPU_TYPE_SPARC     = 14
    CPU_TYPE_POWERPC   = 18
    CPU_TYPE_POWERPC64 = CPU_TYPE_POWERPC | CPU_ARCH_ABI64
    CPU_TYPE_ARM64     = CPU_TYPE_ARM | CPU_ARCH_ABI64

    private_constant :CPU_ARCH_ABI64, :CPU_TYPE_X86, :CPU_TYPE_X86_64, :CPU_TYPE_ARM
    private_constant :CPU_TYPE_SPARC, :CPU_TYPE_POWERPC, :CPU_TYPE_POWERPC64

    attach_function(
      :sysctl,
      %i[pointer uint pointer pointer pointer size_t],
      :int
    )

    private_class_method :sysctl

    attach_function(
      :sysctlbyname,
      %i[string pointer pointer pointer size_t],
      :int
    )

    private_class_method :sysctlbyname

    attach_function :getloadavg, %i[pointer int], :int
    attach_function :sysconf, [:int], :long

    private_class_method :getloadavg
    private_class_method :sysconf

    # Private wrapper class for struct clockinfo
    class ClockInfo < FFI::Struct
      layout(
        :hz, :int,
        :tick, :int,
        :spare, :int,
        :stathz, :int,
        :profhz, :int
      )
    end

    private_constant :ClockInfo

    # Returns the cpu's architecture. On most systems this will be identical
    # to the CPU.machine method. On OpenBSD it will be identical to the CPU.model
    # method.
    #
    def self.architecture
      optr = FFI::MemoryPointer.new(:char, 256)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_int(optr.size)

      if sysctlbyname('hw.machine', optr, size, nil, 0) < 0
        raise Error, 'sysctlbyname function failed'
      end

      optr.read_string
    end

    def self.logical_cpu
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(optr.size)

      if sysctlbyname('hw.logicalcpu', optr, size, nil, 0) < 0
        raise Error, 'sysctlbyname failed'
      end

      optr.read_long
    end

    def self.physical_cpu
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(optr.size)

      if sysctlbyname('hw.physicalcpu', optr, size, nil, 0) < 0
        raise Error, 'sysctlbyname failed'
      end

      optr.read_long
    end

    def self.active_cpu
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(optr.size)

      if sysctlbyname('hw.activecpu', optr, size, nil, 0) < 0
        raise Error, 'sysctlbyname failed'
      end

      optr.read_long
    end

    # Returns the number of cpu's on your system. Note that each core on
    # multi-core systems are counted as a cpu, e.g. one dual core cpu would
    # return 2, not 1.
    #
    def self.num_cpu
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(optr.size)

      if sysctlbyname('hw.ncpu', optr, size, nil, 0) < 0
        raise Error, 'sysctlbyname failed'
      end

      optr.read_long
    end

    # Returns the cpu's class type. On most systems this will be identical
    # to the CPU.architecture method. On OpenBSD it will be identical to the
    # CPU.model method.
    #
    def self.machine
      buf  = 0.chr * 32
      mib  = FFI::MemoryPointer.new(:int, 2)
      size = FFI::MemoryPointer.new(:long, 1)

      mib.write_array_of_int([CTL_HW, HW_MACHINE])
      size.write_int(buf.size)

      if sysctl(mib, 2, buf, size, nil, 0) < 0
        raise Error, 'sysctl function failed'
      end

      buf.strip
    end

    # Returns a string indicating the cpu model.
    #
    def self.model(subtype: false)
      ptr  = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(ptr.size)

      if sysctlbyname('hw.cputype', ptr, size, nil, 0) < 0
        raise 'sysctlbyname function failed'
      end

      str = case ptr.read_long
        when CPU_TYPE_X86, CPU_TYPE_X86_64
          'Intel'
        when CPU_TYPE_SPARC
          'Sparc'
        when CPU_TYPE_POWERPC, CPU_TYPE_POWERPC64
          'PowerPC'
        when CPU_TYPE_ARM, CPU_TYPE_ARM64
          'ARM'
        else
          'Unknown'
      end

      if subtype
        ptr.clear
        if sysctlbyname('hw.cpusubtype', ptr, size, nil, 0) < 0
          raise 'sysctlbyname function failed'
        end

        case ptr.read_long
          when 2
            str += '64'
        end
      end

      str
    end

    # Returns an integer indicating the speed of the CPU.
    #
    def self.freq
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)

      size.write_long(optr.size)

      if RbConfig::CONFIG['host_cpu'] =~ /^arm|^aarch/i
        if sysctlbyname('hw.tbfrequency', optr, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed on hw.tbfrequency'
        end

        size.clear
        clock = ClockInfo.new
        size.write_long(clock.size)

        if sysctlbyname('kern.clockrate', clock, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed on kern.clockrate'
        end

        (optr.read_long * clock[:hz]) / 1_000_000
      else
        if sysctlbyname('hw.cpufrequency', optr, size, nil, 0) < 0
          raise Error, 'sysctlbyname failed on hw.cpufrequency'
        end
        optr.read_long / 1_000_000
      end
    end

    # Returns an array of three floats indicating the 1, 5 and 15 minute load
    # average.
    #
    def self.load_avg
      loadavg = FFI::MemoryPointer.new(:double, 3)

      if getloadavg(loadavg, loadavg.size) < 0
        raise Error, 'getloadavg function failed'
      end

      loadavg.get_array_of_double(0, 3)
    end

    # Returns a comprehensive hash of CPU information including architecture,
    # core counts, frequencies, cache sizes, feature flags, and load averages.
    # This method collects all pertinent CPU-related information available on macOS.
    #
    # The returned hash includes:
    # - Basic info: architecture, machine type, model, brand string
    # - CPU topology: core counts, thread counts, performance levels (Apple Silicon)
    # - Performance: frequency, timebase frequency, load averages
    # - Memory: total memory, usable memory, page sizes
    # - Cache: L1/L2/L3 sizes, cache line size, cache configuration
    # - Features: ARM features, instruction set extensions, capability flags
    #
    # Example:
    #   info = Sys::CPU.info
    #   puts info[:brand_string]  # => "Apple M4 Max"
    #   puts info[:physical_cpu]  # => 16
    #   puts info[:cache][:l2_size]  # => 4194304
    #
    def self.info
      info_hash = {}

      # Basic CPU information
      info_hash[:architecture] = architecture
      info_hash[:machine] = machine
      info_hash[:model] = model(subtype: true)

      # CPU counts and topology
      info_hash[:num_cpu] = num_cpu
      info_hash[:logical_cpu] = logical_cpu
      info_hash[:physical_cpu] = physical_cpu
      info_hash[:active_cpu] = active_cpu

      # Performance levels (Apple Silicon specific)
      begin
        perf_levels = get_performance_levels
        info_hash[:performance_levels] = perf_levels unless perf_levels.nil?
      rescue Error
        # Not available on all systems
      end

      # Core topology
      begin
        info_hash[:cores_per_package] = get_sysctl_int('machdep.cpu.cores_per_package')
        info_hash[:core_count] = get_sysctl_int('machdep.cpu.core_count')
        info_hash[:logical_per_package] = get_sysctl_int('machdep.cpu.logical_per_package')
        info_hash[:thread_count] = get_sysctl_int('machdep.cpu.thread_count')
      rescue Error
        # Not available on all systems
      end

      # Brand string
      begin
        info_hash[:brand_string] = get_sysctl_string('machdep.cpu.brand_string')
      rescue Error
        # Fallback to model if brand string unavailable
        info_hash[:brand_string] = model
      end

      # Frequency information
      info_hash[:frequency_mhz] = freq

      # Timebase frequency (important for Apple Silicon)
      begin
        info_hash[:timebase_frequency] = get_sysctl_long('hw.tbfrequency')
      rescue Error
        # Not available on all systems
      end

      # Cache information
      cache_info = get_cache_info
      info_hash[:cache] = cache_info unless cache_info.empty?

      # Memory information
      begin
        info_hash[:memory_size] = get_sysctl_long('hw.memsize')
        info_hash[:memory_usable] = get_sysctl_long('hw.memsize_usable')
        info_hash[:page_size] = get_sysctl_int('hw.pagesize')
        info_hash[:page_size_32] = get_sysctl_int('hw.pagesize32')
      rescue Error
        # Not available on all systems
      end

      # CPU type information
      begin
        info_hash[:cpu_type] = get_sysctl_int('hw.cputype')
        info_hash[:cpu_subtype] = get_sysctl_int('hw.cpusubtype')
      rescue Error
        # Not available on all systems
      end

      # CPU features and capabilities
      features = get_cpu_features
      info_hash[:features] = features unless features.empty?

      # Load averages
      info_hash[:load_avg] = load_avg

      # Byte order
      begin
        info_hash[:byte_order] = get_sysctl_int('hw.byteorder')
      rescue Error
        # Not available on all systems
      end

      # Additional hardware info
      begin
        info_hash[:cpu_freq_max] = get_sysctl_long('hw.cpufrequency_max')
      rescue Error
        # Not available on all systems
      end

      begin
        info_hash[:cpu_freq_min] = get_sysctl_long('hw.cpufrequency_min')
      rescue Error
        # Not available on all systems
      end

      # OS version information (helpful for context)
      begin
        info_hash[:os_type] = get_sysctl_string('kern.ostype')
        info_hash[:os_release] = get_sysctl_string('kern.osrelease')
        info_hash[:os_version] = get_sysctl_string('kern.version').split("\n").first
      rescue Error
        # Not available on all systems
      end

      info_hash
    end

    private

    # Helper method to get integer sysctl values
    def self.get_sysctl_int(name)
      optr = FFI::MemoryPointer.new(:int)
      size = FFI::MemoryPointer.new(:size_t)
      size.write_long(optr.size)

      if sysctlbyname(name, optr, size, nil, 0) < 0
        raise Error, "sysctlbyname failed for #{name}"
      end

      optr.read_int
    end

    # Helper method to get long sysctl values
    def self.get_sysctl_long(name)
      optr = FFI::MemoryPointer.new(:long)
      size = FFI::MemoryPointer.new(:size_t)
      size.write_long(optr.size)

      if sysctlbyname(name, optr, size, nil, 0) < 0
        raise Error, "sysctlbyname failed for #{name}"
      end

      optr.read_long
    end

    # Helper method to get string sysctl values
    def self.get_sysctl_string(name)
      # First get the required size
      size = FFI::MemoryPointer.new(:size_t)
      if sysctlbyname(name, nil, size, nil, 0) < 0
        raise Error, "sysctlbyname failed for #{name} (size check)"
      end

      # Allocate buffer and get the string
      buffer_size = size.read_long
      optr = FFI::MemoryPointer.new(:char, buffer_size)
      size.write_long(buffer_size)

      if sysctlbyname(name, optr, size, nil, 0) < 0
        raise Error, "sysctlbyname failed for #{name}"
      end

      optr.read_string
    end

    # Get performance level information (Apple Silicon specific)
    def self.get_performance_levels
      levels = {}
      level = 0

      loop do
        begin
          prefix = "hw.perflevel#{level}"
          level_info = {}
          level_info[:physical_cpu] = get_sysctl_int("#{prefix}.physicalcpu")
          level_info[:physical_cpu_max] = get_sysctl_int("#{prefix}.physicalcpu_max")
          level_info[:logical_cpu] = get_sysctl_int("#{prefix}.logicalcpu")
          level_info[:logical_cpu_max] = get_sysctl_int("#{prefix}.logicalcpu_max")
          level_info[:cpus_per_l2] = get_sysctl_int("#{prefix}.cpusperl2")
          levels[level] = level_info
          level += 1
        rescue Error
          break
        end
      end

      levels.empty? ? nil : levels
    end

    # Get cache information
    def self.get_cache_info
      cache = {}

      begin
        cache[:line_size] = get_sysctl_int('hw.cachelinesize')
        cache[:l1_instruction_size] = get_sysctl_int('hw.l1icachesize')
        cache[:l1_data_size] = get_sysctl_int('hw.l1dcachesize')
        cache[:l2_size] = get_sysctl_int('hw.l2cachesize')
      rescue Error
        # Some cache info may not be available
      end

      # Try to get L3 cache size
      begin
        cache[:l3_size] = get_sysctl_int('hw.l3cachesize')
      rescue Error
        # L3 cache may not be present or reported
      end

      # Get cache configuration as array
      begin
        config_ptr = FFI::MemoryPointer.new(:long, 10)
        size = FFI::MemoryPointer.new(:size_t)
        size.write_long(config_ptr.size)

        if sysctlbyname('hw.cacheconfig', config_ptr, size, nil, 0) >= 0
          config_values = config_ptr.get_array_of_long(0, 10).take_while { |x| x != 0 }
          unless config_values.empty?
            cache[:config] = {
              cpu_count: config_values[0],
              l1_sets: config_values[1],
              l2_sets: config_values[2],
              l3_sets: config_values[3]
            }.compact
          end
        end
      rescue Error
        # Cache config may not be available
      end

      # Get cache sizes as array with labels
      begin
        sizes_ptr = FFI::MemoryPointer.new(:long, 10)
        size = FFI::MemoryPointer.new(:size_t)
        size.write_long(sizes_ptr.size)

        if sysctlbyname('hw.cachesize', sizes_ptr, size, nil, 0) >= 0
          size_values = sizes_ptr.get_array_of_long(0, 10).take_while { |x| x != 0 }
          unless size_values.empty?
            cache[:sizes] = {
              total: size_values[0],
              l1: size_values[1],
              l2: size_values[2],
              l3: size_values[3]
            }.compact
          end
        end
      rescue Error
        # Cache sizes may not be available
      end

      cache
    end

    # Get CPU features and capabilities
    def self.get_cpu_features
      features = {}

      # ARM-specific features (for Apple Silicon)
      arm_features = %w[
        AdvSIMD AdvSIMD_HPFPCvt SME_F32F32 SME_BI32I32 SME_B16F32 SME_F16F32
        SME_I8I32 SME_I16I32 FP_SyncExceptions
      ]

      arm_features.each do |feature|
        begin
          value = get_sysctl_int("hw.optional.arm.#{feature}")
          features["arm_#{feature.downcase}"] = value == 1
        rescue Error
          # Feature not available
        end
      end

      # General optional features
      optional_features = %w[
        floatingpoint neon neon_hpfp neon_fp16 armv8_crc32 armv8_gpi
        armv8_1_atomics armv8_2_fhm armv8_2_sha512 armv8_2_sha3
      ]

      optional_features.each do |feature|
        begin
          value = get_sysctl_int("hw.optional.#{feature}")
          features[feature] = value == 1
        rescue Error
          # Feature not available
        end
      end

      # ARM capability bits
      begin
        features[:arm_caps] = get_sysctl_long('hw.optional.arm.caps')
      rescue Error
        # Not available
      end

      # SME max SVL
      begin
        features[:sme_max_svl_b] = get_sysctl_int('hw.optional.arm.sme_max_svl_b')
      rescue Error
        # Not available
      end

      # Get all FEAT_ flags
      feat_flags = {}
      feat_names = %w[
        CRC32 FlagM FlagM2 FHM DotProd SHA3 RDM LSE SHA256 SHA512 SHA1 AES
        PMULL SPECRES SPECRES2 SB FRINTTS LRCPC LRCPC2 FCMA JSCVT PAuth
        PAuth2 FPAC FPACCOMBINE DPB DPB2 BF16 I8MM
      ]

      feat_names.each do |feat|
        begin
          value = get_sysctl_int("hw.optional.arm.FEAT_#{feat}")
          feat_flags["feat_#{feat.downcase}"] = value == 1
        rescue Error
          # Feature not available
        end
      end

      features[:feat_flags] = feat_flags unless feat_flags.empty?
      features
    end

    private_class_method :get_sysctl_int, :get_sysctl_long, :get_sysctl_string
    private_class_method :get_performance_levels, :get_cache_info, :get_cpu_features
  end
end

if $0 == __FILE__
  puts "Basic CPU methods:"
  puts "Active CPUs: #{Sys::CPU.active_cpu}"
  puts "Architecture: #{Sys::CPU.architecture}"
  puts "Machine: #{Sys::CPU.machine}"
  puts "Model: #{Sys::CPU.model(subtype: true)}"

  puts "\nTesting comprehensive info method..."
  info = Sys::CPU.info
  puts "Brand: #{info[:brand_string]}"
  puts "Physical CPUs: #{info[:physical_cpu]}"
  puts "Memory: #{(info[:memory_size] / 1024.0**3).round(2)} GB" if info[:memory_size]
  puts "Features count: #{info[:features].size}" if info[:features]
  puts "\nFor detailed output, see examples/example_sys_cpu_info_darwin.rb"
end
