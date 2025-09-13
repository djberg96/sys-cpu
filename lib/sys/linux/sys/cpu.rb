# frozen_string_literal: true

require_relative 'cpu_human_readable'

##########################################################
# linux.rb (sys-cpu) - pure Ruby version for Linux
##########################################################

# The Sys module is a namespace only.
module Sys
  # :stopdoc:

  cpu_file  = '/proc/cpuinfo'
  cpu_hash  = {}

  # rubocop:disable Style/MutableConstant
  CPU_ARRAY = []
  # rubocop:enable Style/MutableConstant

  private_constant :CPU_ARRAY

  # Parse the info out of the /proc/cpuinfo file
  File.foreach(cpu_file) do |line|
    line.strip!
    next if line.empty?

    key, val = line.split(':')
    key.strip!
    key.gsub!(/\s+/, '_')
    key.downcase!
    val.strip! if val

    if cpu_hash.key?(key)
      CPU_ARRAY.push(cpu_hash.dup)
      cpu_hash.clear
    end

    # Turn yes/no attributes into booleans
    val = true if val == 'yes'
    val = false if val == 'no'

    cpu_hash[key] = val
  end

  CPU_ARRAY.push(cpu_hash)

  # :startdoc:

  # The CPU class encapsulates information about physical CPUs on your system.
  class CPU
    # :stopdoc:

    CPUStruct = Struct.new('CPUStruct', *CPU_ARRAY.first.keys)

    private_constant :CPUStruct

    # :startdoc:

    # In block form, yields a CPUStruct for each CPU on the system.  In
    # non-block form, returns an Array of CPUStruct's.
    #
    # The exact members of the struct vary on Linux systems.
    #
    def self.processors(human_readable: false)
      array = []
      CPU_ARRAY.each do |hash|
        new_hash = hash.dup
        if human_readable
          # Only attempt to convert if the field exists
          if new_hash.key?('cpu_implementer') && Sys::LinuxCpuHumanReadable::IMPLEMENTER[new_hash['cpu_implementer']]
            new_hash['cpu_implementer'] = Sys::LinuxCpuHumanReadable::IMPLEMENTER[new_hash['cpu_implementer']]
          end
          if new_hash.key?('cpu_architecture') && Sys::LinuxCpuHumanReadable::ARCHITECTURE[new_hash['cpu_architecture']]
            new_hash['cpu_architecture'] = Sys::LinuxCpuHumanReadable::ARCHITECTURE[new_hash['cpu_architecture']]
          end
          # Add more fields as needed (variant, part, revision)
        end
        struct = CPUStruct.new
        struct.members.each{ |m| struct.send("#{m}=", new_hash[m.to_s]) }
        if block_given?
          yield struct
        else
          array << struct
        end
      end
      array unless block_given?
    end

    # Return the total number of logical CPU on the system.
    #
    def self.num_cpu
      CPU_ARRAY.size
    end

    # Return the architecture of the CPU.
    #
    def self.architecture
      case CPU_ARRAY.first['cpu_family']
        when '3'
          'x86'
        when '4'
          'i486'
        when '5'
          'Pentium'
        when '6'
          'x86_64'
        when '15'
          'Netburst'
        else
          'Unknown'
      end
    end

    # Returns a string indicating the CPU model.
    #
    def self.model
      CPU_ARRAY.first['model_name']
    end

    # Returns an integer indicating the speed of the CPU.
    #
    def self.freq
      CPU_ARRAY.first['cpu_mhz'].to_f.round
    end

    # Create singleton methods for each of the attributes.
    #
    def self.method_missing(id, arg = 0)
      raise NoMethodError, "'#{id}'" unless CPU_ARRAY[arg].key?(id.to_s)
      rv = CPU_ARRAY[arg][id.to_s]
      if rv.nil?
        id = "#{id}?"
        rv = CPU_ARRAY[arg][id]
      end
      rv
    end

    def self.respond_to_missing?(method, _private_methods = false)
      CPU_ARRAY.first.keys.include?(method.to_s)
    end

    private_class_method :method_missing

    # Returns a 3 element Array corresponding to the 1, 5 and 15 minute
    # load average for the system.
    #
    def self.load_avg
      load_avg_file = '/proc/loadavg'
      File.readlines(load_avg_file).first.split[0..2].map(&:to_f)
    end

    # Returns a comprehensive hash of system CPU and hardware information.
    # This provides a convenient way to get all available CPU information
    # in a single call.
    #
    # Example:
    #   info = Sys::CPU.info
    #   puts info[:architecture]    # => "x86_64"
    #   puts info[:num_cpu]         # => 8
    #   puts info[:memory_total]    # => 16777216
    #
    def self.info
      info_hash = {}

      # Basic CPU information
      info_hash[:architecture] = architecture
      info_hash[:model] = model
      info_hash[:frequency_mhz] = freq
      info_hash[:num_cpu] = num_cpu

      # CPU details from first processor
      first_cpu = CPU_ARRAY.first
      info_hash[:vendor_id] = first_cpu['vendor_id'] if first_cpu['vendor_id']
      info_hash[:cpu_family] = first_cpu['cpu_family'] if first_cpu['cpu_family']
      info_hash[:model_number] = first_cpu['model'] if first_cpu['model']
      info_hash[:stepping] = first_cpu['stepping'] if first_cpu['stepping']
      info_hash[:microcode] = first_cpu['microcode'] if first_cpu['microcode']
      info_hash[:cache_size] = first_cpu['cache_size'] if first_cpu['cache_size']

      # ARM-specific fields (if present)
      info_hash[:cpu_implementer] = first_cpu['cpu_implementer'] if first_cpu['cpu_implementer']
      info_hash[:cpu_architecture] = first_cpu['cpu_architecture'] if first_cpu['cpu_architecture']
      info_hash[:cpu_variant] = first_cpu['cpu_variant'] if first_cpu['cpu_variant']
      info_hash[:cpu_part] = first_cpu['cpu_part'] if first_cpu['cpu_part']
      info_hash[:cpu_revision] = first_cpu['cpu_revision'] if first_cpu['cpu_revision']

      # CPU features/flags
      info_hash[:flags] = first_cpu['flags'].split(' ') if first_cpu['flags']
      info_hash[:features] = first_cpu['features'].split(' ') if first_cpu['features'] # ARM

      # Load averages
      info_hash[:load_avg] = load_avg

      # CPU statistics
      info_hash[:cpu_stats] = cpu_stats

      # Memory information from /proc/meminfo
      begin
        meminfo = parse_meminfo
        info_hash[:memory_total] = meminfo['MemTotal']
        info_hash[:memory_free] = meminfo['MemFree']
        info_hash[:memory_available] = meminfo['MemAvailable']
        info_hash[:swap_total] = meminfo['SwapTotal']
        info_hash[:swap_free] = meminfo['SwapFree']
      rescue => e
        # Memory info not available
      end

      # System information from /proc/version
      begin
        info_hash[:kernel_version] = File.read('/proc/version').strip
      rescue => e
        # Version info not available
      end

      # Uptime information
      begin
        uptime_data = File.read('/proc/uptime').strip.split
        info_hash[:uptime_seconds] = uptime_data[0].to_f
        info_hash[:idle_time_seconds] = uptime_data[1].to_f
      rescue => e
        # Uptime info not available
      end

      # Virtualization detection
      begin
        if File.exist?('/proc/xen')
          info_hash[:virtualization] = 'Xen'
        elsif File.exist?('/proc/vz')
          info_hash[:virtualization] = 'OpenVZ'
        elsif File.read('/proc/cpuinfo').include?('hypervisor')
          info_hash[:virtualization] = 'VM (hypervisor detected)'
        end
      rescue => e
        # Virtualization detection failed
      end

      info_hash
    end

    private

    # Parse /proc/meminfo into a hash
    def self.parse_meminfo
      meminfo = {}
      File.foreach('/proc/meminfo') do |line|
        line.strip!
        next if line.empty?

        key, value = line.split(':')
        next unless key && value

        key = key.strip
        value = value.strip.gsub(/\s*kB$/, '').to_i * 1024 # Convert kB to bytes
        meminfo[key] = value
      end
      meminfo
    end

    private_class_method :parse_meminfo

    # Returns a hash of arrays that contains an array of the following
    # information (as of 2.6.33), respectively:
    #
    # * user: time spent in user mode.
    # * nice: time spent in user mode with low priority.
    # * system: time spent in system mode.
    # * idle: time spent in the idle task.
    # * iowait: time waiting for IO to complete.
    # * irq: time servicing interrupts.
    # * softirq: time servicing softirqs.
    # * steal: time spent in other operating systems when running in a virtualized environment.
    # * guest: time spent running a virtual CPU for guest operating systems.
    # * guest_nice: time spent running a niced guest, i.e a virtual CPU for guest operating systems.
    #
    # Note that older kernels may not necessarily include some of these fields.
    #
    def self.cpu_stats
      cpu_stat_file = '/proc/stat'
      hash = {} # Hash needed for multi-cpu systems

      lines = File.readlines(cpu_stat_file)

      lines.each_with_index do |line, i|
        array = line.split
        break unless array[0] =~ /cpu/ # 'cpu' entries always on top

        # Some machines list a 'cpu' and a 'cpu0'. In this case only
        # return values for the numbered cpu entry.
        if lines[i].split[0] == 'cpu' && lines[i + 1].split[0] =~ /cpu\d/
          next
        end

        vals = array[1..-1].map{ |e| e.to_i / 100 } # 100 jiffies/sec.
        hash[array[0]] = vals
      end

      hash
    end
  end
end

if $0 == __FILE__
  require 'pp'
  pp Sys::CPU.info
end
