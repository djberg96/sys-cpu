##########################################################
# linux.rb (sys-cpu) - pure Ruby version for Linux
##########################################################
module Sys

  # :stopdoc:

  cpu_file   = "/proc/cpuinfo"
  cpu_hash   = {}
  CPU_ARRAY = []

  # Parse the info out of the /proc/cpuinfo file
  IO.foreach(cpu_file){ |line|
    line.strip!
    next if line.empty?

    key, val = line.split(":")
    key.strip!
    key.gsub!(/\s+/,"_")
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
  }

  CPU_ARRAY.push(cpu_hash)

  # :startdoc:

  class CPU

    # :stopdoc:

    CPUStruct = Struct.new("CPUStruct", *CPU_ARRAY.first.keys)

    # :startdoc:

    # In block form, yields a CPUStruct for each CPU on the system.  In
    # non-block form, returns an Array of CPUStruct's.
    #
    # The exact members of the struct vary on Linux systems.
    #
    def self.processors
      array = []
      CPU_ARRAY.each{ |hash|
        struct = CPUStruct.new
        struct.members.each{ |m| struct.send("#{m}=", hash["#{m}"]) }
        if block_given?
          yield struct
        else
          array << struct
        end
      }
      array unless block_given?
    end

    private

    # Create singleton methods for each of the attributes.
    #
    def self.method_missing(id, arg=0)
      rv = CPU_ARRAY[arg][id.to_s]
      if rv.nil?
        id = id.to_s + "?"
        rv = CPU_ARRAY[arg][id]
      end
      rv
    end

    public

    # Returns a 3 element Array corresponding to the 1, 5 and 15 minute
    # load average for the system.
    #
    def self.load_avg
      load_avg_file = "/proc/loadavg"
      IO.readlines(load_avg_file).first.split[0..2].map{ |e| e.to_f }
    end

    # Returns a hash of arrays that contain the number of seconds that the
    # system spent in user mode, user mode with low priority (nice), system
    # mode, and the idle task, respectively.
    #
    def self.cpu_stats
      cpu_stat_file = "/proc/stat"
      hash = {} # Hash needed for multi-cpu systems

      lines = IO.readlines(cpu_stat_file)

      lines.each_with_index{ |line, i|
        array = line.split
        break unless array[0] =~ /cpu/   # 'cpu' entries always on top

        # Some machines list a 'cpu' and a 'cpu0'. In this case only
        # return values for the numbered cpu entry.
        if lines[i].split[0] == "cpu" && lines[i+1].split[0] =~ /cpu\d/
          next
        end

        vals = array[1..-1].map{ |e| e = e.to_i / 100 } # 100 jiffies/sec.
        hash[array[0]] = vals
      }

      hash
    end
  end
end
