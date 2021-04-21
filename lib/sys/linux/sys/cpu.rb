# frozen_string_literal: true

##########################################################
# linux.rb (sys-cpu) - pure Ruby version for Linux
##########################################################
module Sys

  # :stopdoc:

  cpu_file   = '/proc/cpuinfo'
  cpu_hash   = {}
  CPU_ARRAY = []

  private_constant :CPU_ARRAY

  # Parse the info out of the /proc/cpuinfo file
  IO.foreach(cpu_file) do |line|
    line.strip!
    next if line.empty?

    key, val = line.split(':')
    key.strip!
    key.gsub!(/\s+/,'_')
    key.downcase!
    val.strip! if val

    if cpu_hash.has_key?(key)
      CPU_ARRAY.push(cpu_hash.dup)
      cpu_hash.clear
    end

    # Turn yes/no attributes into booleans
    if val == 'yes'
      val = true
    elsif val == 'no'
      val = false
    end

    cpu_hash[key] = val
  end

  CPU_ARRAY.push(cpu_hash)

  # :startdoc:

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
    def self.processors
      array = []
      CPU_ARRAY.each do |hash|
        struct = CPUStruct.new
        struct.members.each{ |m| struct.send("#{m}=", hash["#{m}"]) }
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
        when '6'
          'x86_64'
        else
          nil
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
      raise NoMethodError, "'#{id}'" unless CPU_ARRAY[arg].has_key?(id.to_s)
      rv = CPU_ARRAY[arg][id.to_s]
      if rv.nil?
        id = id.to_s + '?'
        rv = CPU_ARRAY[arg][id]
      end
      rv
    end

    private_class_method :method_missing

    # Returns a 3 element Array corresponding to the 1, 5 and 15 minute
    # load average for the system.
    #
    def self.load_avg
      load_avg_file = '/proc/loadavg'
      IO.readlines(load_avg_file).first.split[0..2].map(&:to_f)
    end

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

      lines = IO.readlines(cpu_stat_file)

      lines.each_with_index do |line, i|
        array = line.split
        break unless array[0] =~ /cpu/ # 'cpu' entries always on top

        # Some machines list a 'cpu' and a 'cpu0'. In this case only
        # return values for the numbered cpu entry.
        if lines[i].split[0] == 'cpu' && lines[i+1].split[0] =~ /cpu\d/
          next
        end

        vals = array[1..-1].map{ |e| e.to_i / 100 } # 100 jiffies/sec.
        hash[array[0]] = vals
      end

      hash
    end
  end
end
