require 'win32ole'
require 'socket'

# See Ruby bugs #2618 and #7681. This is a workaround.
BEGIN{
  require 'win32ole'
  if RUBY_VERSION.to_f < 2.0
    WIN32OLE.ole_initialize
    at_exit { WIN32OLE.ole_uninitialize }
  end
}

# The Sys module serves only as a namespace
module Sys
  # Encapsulates system CPU information
  class CPU
    # Error raised if any of the Sys::CPU methods fail.
    class Error < StandardError; end

    private

    # Base connect string
    BASE_CS = "winmgmts:{impersonationLevel=impersonate}" # :nodoc:

    # Fields used in the CPUStruct
    fields = %w[
      address_width
      architecture
      availability
      caption
      config_manager_error_code
      config_manager_user_config
      cpu_status
      creation_class_name
      freq
      voltage
      data_width
      description
      device_id
      error_cleared?
      error_description
      ext_clock
      family
      install_date
      l2_cache_size
      l2_cache_speed
      last_error_code
      level
      load_avg
      manufacturer
      max_clock_speed
      name
      other_family_description
      pnp_device_id
      power_management_supported?
      power_management_capabilities
      processor_id
      processor_type
      revision
      role
      socket_designation
      status
      status_info
      stepping
      system_creation_class_name
      system_name
      unique_id
      upgrade_method
      version
      voltage_caps
    ]

    # The struct returned by the CPU.processors method
    CPUStruct = Struct.new("CPUStruct", *fields) # :nodoc:

    public

    # Returns the +host+ CPU's architecture, or nil if it cannot be
    # determined.
    #
    def self.architecture(host=Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu0'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        self.get_cpu_arch(wmi.Architecture)
      end
    end

    # Returns an integer indicating the speed (i.e. frequency in Mhz) of
    # +cpu_num+ on +host+, or the localhost if no +host+ is specified.
    # If +cpu_num+ +1 is greater than the number of cpu's on your system
    # or this call fails for any other reason, a Error is raised.
    #
    def self.freq(cpu_num = 0, host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu#{cpu_num}'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        return wmi.CurrentClockSpeed
      end
    end

    # Returns the load capacity for +cpu_num+ on +host+, or the localhost
    # if no host is specified, averaged to the last second. Processor
    # loading refers to the total computing burden for each processor at
    # one time.
    #
    # Note that this attribute is actually the LoadPercentage.  I may use
    # one of the Win32_Perf* classes in the future.
    #
    def self.load_avg(cpu_num = 0, host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu#{cpu_num}'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        return wmi.LoadPercentage
      end
    end

    # Returns a string indicating the cpu model, e.g. Intel Pentium 4.
    #
    def self.model(host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu0'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        return wmi.Name
      end
    end

    # Returns an integer indicating the number of cpu's on the system.
    #--
    # This (oddly) requires a different class.
    #
    def self.num_cpu(host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_ComputerSystem='#{host}'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        return wmi.NumberOfProcessors
      end
    end

    # Returns a CPUStruct for each CPU on +host+, or the localhost if no
    # +host+ is specified.  A CPUStruct contains the following members:
    #
    # * address_width
    # * architecture
    # * availability
    # * caption
    # * config_manager_error_code
    # * config_manager_user_config
    # * cpu_status
    # * creation_class_name
    # * freq
    # * voltage
    # * data_width
    # * description
    # * device_id
    # * error_cleared?
    # * error_description
    # * ext_clock
    # * family
    # * install_date
    # * l2_cache_size
    # * l2_cache_speed
    # * last_error_code
    # * level
    # * load_avg
    # * manufacturer
    # * max_clock_speed
    # * name
    # * other_family_description
    # * pnp_device_id
    # * power_management_supported?
    # * power_management_capabilities
    # * processor_id
    # * processor_type
    # * revision
    # * role
    # * socket_designation
    # * status
    # * status_info
    # * stepping
    # * system_creation_class_name
    # * system_name
    # * unique_id
    # * upgrade_method
    # * version
    # * voltage_caps
    #
    # Note that not all of these members will necessarily be defined.
    #
    def self.processors(host = Socket.gethostname) # :yields: CPUStruct
      begin
        wmi = WIN32OLE.connect(BASE_CS + "//#{host}/root/cimv2")
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        wmi.InstancesOf("Win32_Processor").each{ |cpu|
          yield CPUStruct.new(
            cpu.AddressWidth,
            self.get_cpu_arch(cpu.Architecture),
            self.get_availability(cpu.Availability),
            cpu.Caption,
            self.get_cmec(cpu.ConfigManagerErrorCode),
            cpu.ConfigManagerUserConfig,
            get_status(cpu.CpuStatus),
            cpu.CreationClassName,
            cpu.CurrentClockSpeed,
            cpu.CurrentVoltage,
            cpu.DataWidth,
            cpu.Description,
            cpu.DeviceId,
            cpu.ErrorCleared,
            cpu.ErrorDescription,
            cpu.ExtClock,
            self.get_family(cpu.Family),
            cpu.InstallDate,
            cpu.L2CacheSize,
            cpu.L2CacheSpeed,
            cpu.LastErrorCode,
            cpu.Level,
            cpu.LoadPercentage,
            cpu.Manufacturer,
            cpu.MaxClockSpeed,
            cpu.Name,
            cpu.OtherFamilyDescription,
            cpu.PNPDeviceID,
            cpu.PowerManagementSupported,
            cpu.PowerManagementCapabilities,
            cpu.ProcessorId,
            self.get_processor_type(cpu.ProcessorType),
            cpu.Revision,
            cpu.Role,
            cpu.SocketDesignation,
            cpu.Status,
            cpu.StatusInfo,
            cpu.Stepping,
            cpu.SystemCreationClassName,
            cpu.SystemName,
            cpu.UniqueId,
            self.get_upgrade_method(cpu.UpgradeMethod),
            cpu.Version,
            self.get_voltage_caps(cpu.VoltageCaps)
          )
        }
      end
    end

    # Returns a string indicating the type of processor, e.g. GenuineIntel.
    #
    def self.cpu_type(host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu0'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        return wmi.Manufacturer
      end
    end

    private

    # Convert the ConfigManagerErrorCode number to its corresponding string
    # Note that this value returns nil on my system.
    #
    def self.get_cmec(num)
      case
        when 0
          str = "The device is working properly."
          return str
        when 1
          str = "The device is not configured correctly."
          return str
        when 2
          str = "Windows cannot load the driver for the device."
          return str
        when 3
          str = "The driver for the device might be corrupted, or the"
          str << " system may be running low on memory or other"
          str << " resources."
          return str
        when 4
          str = "The device is not working properly. One of the drivers"
          str << " or the registry might be corrupted."
          return str
        when 5
          str = "The driver for this device needs a resource that"
          str << " Windows cannot manage."
          return str
        when 6
          str = "The boot configuration for this device conflicts with"
          str << " other devices."
          return str
        when 7
          str = "Cannot filter."
          return str
        when 8
          str = "The driver loader for the device is missing."
          return str
        when 9
          str = "This device is not working properly because the"
          str << " controlling firmware is reporting the resources"
          str << " for the device incorrectly."
          return str
        when 10
          str = "This device cannot start."
          return str
        when 11
          str = "This device failed."
          return str
        when 12
          str = "This device cannot find enough free resources that"
          str << " it can use."
          return str
        when 13
          str = "Windows cannot verify this device's resources."
          return str
        when 14
          str = "This device cannot work properly until you restart"
          str << " your computer."
          return str
        when 15
          str = "This device is not working properly because there is"
          str << " probably a re-enumeration problem."
          return str
        when 16
           str = "Windows cannot identify all the resources this device "
           str << " uses."
           return str
        when 17
          str = "This device is asking for an unknown resource type."
          return str
        when 18
          str = "Reinstall the drivers for this device."
          return str
        when 19
          str = "Failure using the VXD loader."
          return str
        when 20
          str = "Your registry might be corrupted."
          return str
        when 21
          str = "System failure: try changing the driver for this device."
          str << " If that does not work, see your hardware documentation."
          str << " Windows is removing this device."
          return str
        when 22
          str = "This device is disabled."
          return str
        when 23
          str = "System failure: try changing the driver for this device."
          str << "If that doesn't work, see your hardware documentation."
          return str
        when 24
          str = "This device is not present, not working properly, or"
          str << " does not have all its drivers installed."
          return str
        when 25
          str = "Windows is still setting up this device."
          return str
        when 26
          str = "Windows is still setting up this device."
          return str
        when 27
          str = "This device does not have valid log configuration."
          return str
        when 28
          str = "The drivers for this device are not installed."
          return str
        when 29
          str = "This device is disabled because the firmware of the"
          str << " device did not give it the required resources."
          return str
        when 30
          str = "This device is using an Interrupt Request (IRQ)"
          str << " resource that another device is using."
          return str
        when 31
          str = "This device is not working properly because Windows"
          str << " cannot load the drivers required for this device"
          return str
        else
          return nil
      end
    end

    # Convert an cpu architecture number to a string
    def self.get_cpu_arch(num)
      case num
        when 0
          return "x86"
        when 1
          return "MIPS"
        when 2
          return "Alpha"
        when 3
          return "PowerPC"
        when 6
          return "IA64"
        when 9
          return "x64"
        else
          return nil
      end
    end

    # convert an Availability number into a string
    def self.get_availability(num)
      case num
        when 1
          return "Other"
        when 2
          return "Unknown"
        when 3
          return "Running"
        when 4
          return "Warning"
        when 5
          return "In Test"
        when 6
          return "Not Applicable"
        when 7
          return "Power Off"
        when 8
          return "Off Line"
        when 9
          return "Off Duty"
        when 10
          return "Degraded"
        when 11
          return "Not Installed"
        when 12
          return "Install Error"
        when 13
          return "Power Save - Unknown"
        when 14
          return "Power Save - Low Power Mode"
        when 15
          return "Power Save - Standby"
        when 16
          return "Power Cycle"
        when 17
          return "Power Save - Warning"
        when 18
          return "Paused"
        when 19
          return "Not Ready"
        when 20
          return "Not Configured"
        when 21
          return "Quiesced"
        else
          return nil
      end
    end

    # convert CpuStatus to a string form.  Note that values 5 and 6 are
    # skipped because they're reserved.
    def self.get_status(num)
      case num
        when 0
          return "Unknown"
        when 1
          return "Enabled"
        when 2
          return "Disabled by User via BIOS Setup"
        when 3
          return "Disabled By BIOS (POST Error)"
        when 4
          return "Idle"
        when 7
          return "Other"
        else
          return nil
      end
    end

    # Convert a family number into the equivalent string
    def self.get_family(num)
      case num
        when 1
          return "Other"
        when 2
          return "Unknown"
        when 3
          return "8086"
        when 4
          return "80286"
        when 5
          return "80386"
        when 6
          return "80486"
        when 7
          return "8087"
        when 8
          return "80287"
        when 9
          return "80387"
        when 10
          return "80487"
        when 11
          return "Pentium?"
        when 12
          return "Pentium?"
        when 13
          return "Pentium?"
        when 14
          return "Pentium?"
        when 15
          return "Celeron?"
        when 16
          return "Pentium?"
        when 17
          return "Pentium?"
        when 18
          return "M1"
        when 19
          return "M2"
        when 24
          return "K5"
        when 25
          return "K6"
        when 26
          return "K6-2"
        when 27
          return "K6-3"
        when 28
          return "AMD"
        when 29
          return "AMD?"
        when 30
          return "AMD2900"
        when 31
          return "K6-2+"
        when 32
          return "Power"
        when 33
          return "Power"
        when 34
          return "Power"
        when 35
          return "Power"
        when 36
          return "Power"
        when 37
          return "Power"
        when 38
          return "Power"
        when 39
          return "Power"
        when 48
          return "Alpha"
        when 49
          return "Alpha"
        when 50
          return "Alpha"
        when 51
          return "Alpha"
        when 52
          return "Alpha"
        when 53
          return "Alpha"
        when 54
          return "Alpha"
        when 55
          return "Alpha"
        when 64
          return "MIPS"
        when 65
          return "MIPS"
        when 66
          return "MIPS"
        when 67
          return "MIPS"
        when 68
          return "MIPS"
        when 69
          return "MIPS"
        when 80
          return "SPARC"
        when 81
          return "SuperSPARC"
        when 82
          return "microSPARC"
        when 83
          return "microSPARC"
        when 84
          return "UltraSPARC"
        when 85
          return "UltraSPARC"
        when 86
          return "UltraSPARC"
        when 87
          return "UltraSPARC"
        when 88
          return "UltraSPARC"
        when 96
          return "68040"
        when 97
          return "68xxx"
        when 98
          return "68000"
        when 99
          return "68010"
        when 100
          return "68020"
        when 101
          return "68030"
        when 112
          return "Hobbit"
        when 120
          return "Crusoe?"
        when 121
          return "Crusoe?"
        when 128
          return "Weitek"
        when 130
          return "Itanium?"
        when 144
          return "PA-RISC"
        when 145
          return "PA-RISC"
        when 146
          return "PA-RISC"
        when 147
          return "PA-RISC"
        when 148
          return "PA-RISC"
        when 149
          return "PA-RISC"
        when 150
          return "PA-RISC"
        when 160
          return "V30"
        when 176
          return "Pentium?"
        when 177
          return "Pentium?"
        when 178
          return "Pentium?"
        when 179
          return "Intel?"
        when 180
          return "AS400"
        when 181
          return "Intel?"
        when 182
          return "AMD"
        when 183
          return "AMD"
        when 184
          return "Intel?"
        when 185
          return "AMD"
        when 190
          return "K7"
        when 200
          return "IBM390"
        when 201
          return "G4"
        when 202
          return "G5"
        when 250
          return "i860"
        when 251
          return "i960"
        when 260
          return "SH-3"
        when 261
          return "SH-4"
        when 280
          return "ARM"
        when 281
          return "StrongARM"
        when 300
          return "6x86"
        when 301
          return "MediaGX"
        when 302
          return "MII"
        when 320
          return "WinChip"
        when 350
          return "DSP"
        when 500
          return "Video"
        else
          return nil
      end
    end

    # Convert power management capabilities number to its equivalent string
    def self.get_pmc(num)
      case num
        when 0
          return "Unknown"
        when 1
          return "Not Supported"
        when 2
          return "Disabled"
        when 3
          return "Enabled"
        when 4
          return "Power Saving Modes Entered Automatically"
        when 5
          return "Power State Settable"
        when 6
          return "Power Cycling Supported"
        when 7
          return "Timed Power On Supported"
        else
          return nil
      end
    end

    # Convert a processor type into its equivalent string
    def self.get_processor_type(num)
      case num
        when 1
          return "Other"
        when 2
          return "Unknown"
        when 3
          return "Central Processor"
        when 4
          return "Math Processor"
        when 5
          return "DSP Processor"
        when 6
          return "Video Processor"
        else
          return nil
      end
    end

    # Convert an upgrade method into its equivalent string
    def self.get_upgrade_method(num)
      case num
        when 1
          return "Other"
        when 2
          return "Unknown"
        when 3
          return "Daughter Board"
        when 4
          return "ZIF Socket"
        when 5
          return "Replacement/Piggy Back"
        when 6
          return "None"
        when 7
          return "LIF Socket"
        when 8
          return "Slot 1"
        when 9
          return "Slot 2"
        when 10
          return "370 Pin Socket"
        when 11
          return "Slot A"
        when 12
          return "Slot M"
        else
          return nil
      end
    end

    # Convert return values to voltage cap values (floats)
    def self.get_voltage_caps(num)
      case num
        when 1
          return 5.0
        when 2
          return 3.3
        when 4
          return 2.9
        else
          return nil
      end
    end
  end
end
