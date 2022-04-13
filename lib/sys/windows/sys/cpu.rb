# frozen_string_literal: true

require 'win32ole'
require 'socket'

# The Sys module serves only as a namespace
module Sys
  # Encapsulates system CPU information
  class CPU
    # Error raised if any of the Sys::CPU methods fail.
    class Error < StandardError; end

    # Base connect string
    BASE_CS = 'winmgmts:{impersonationLevel=impersonate}' # :nodoc:

    private_constant :BASE_CS

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
    CPUStruct = Struct.new('CPUStruct', *fields) # :nodoc:

    private_constant :CPUStruct

    # Returns the +host+ CPU's architecture, or nil if it cannot be
    # determined.
    #
    def self.architecture(host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu0'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        get_cpu_arch(wmi.Architecture)
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
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.CurrentClockSpeed
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
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.LoadPercentage
      end
    end

    # Returns a string indicating the cpu model, e.g. Intel Pentium 4.
    #
    def self.model(host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu0'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.Name
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
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.NumberOfProcessors
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
    #--
    # rubocop:disable Metrics/BlockLength
    def self.processors(host = Socket.gethostname) # :yields: CPUStruct
      begin
        wmi = WIN32OLE.connect(BASE_CS + "//#{host}/root/cimv2")
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.InstancesOf('Win32_Processor').each do |cpu|
          yield CPUStruct.new(
            cpu.AddressWidth,
            get_cpu_arch(cpu.Architecture),
            get_availability(cpu.Availability),
            cpu.Caption,
            get_cmec(cpu.ConfigManagerErrorCode),
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
            get_family(cpu.Family),
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
            get_processor_type(cpu.ProcessorType),
            cpu.Revision,
            cpu.Role,
            cpu.SocketDesignation,
            cpu.Status,
            cpu.StatusInfo,
            cpu.Stepping,
            cpu.SystemCreationClassName,
            cpu.SystemName,
            cpu.UniqueId,
            get_upgrade_method(cpu.UpgradeMethod),
            cpu.Version,
            get_voltage_caps(cpu.VoltageCaps)
          )
        end
      end
    end

    # rubocop:enable Metrics/BlockLength

    # Returns a string indicating the type of processor, e.g. GenuineIntel.
    #
    def self.cpu_type(host = Socket.gethostname)
      cs = BASE_CS + "//#{host}/root/cimv2:Win32_Processor='cpu0'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.Manufacturer
      end
    end

    private

    # Convert the ConfigManagerErrorCode number to its corresponding string
    # Note that this value returns nil on my system.
    #
    def self.get_cmec(num)
      case num
        when 0
          'The device is working properly.'
        when 1
          'The device is not configured correctly.'
        when 2
          'Windows cannot load the driver for the device.'
        when 3
          str = 'The driver for the device might be corrupted, or the'
          str << ' system may be running low on memory or other'
          str << ' resources.'
          str
        when 4
          str = 'The device is not working properly. One of the drivers'
          str << ' or the registry might be corrupted.'
          str
        when 5
          str = 'The driver for this device needs a resource that'
          str << ' Windows cannot manage.'
          str
        when 6
          str = 'The boot configuration for this device conflicts with'
          str << ' other devices.'
          str
        when 7
          'Cannot filter.'
        when 8
          'The driver loader for the device is missing.'
        when 9
          str = 'This device is not working properly because the'
          str << ' controlling firmware is reporting the resources'
          str << ' for the device incorrectly.'
          str
        when 10
          'This device cannot start.'
        when 11
          'This device failed.'
        when 12
          str = 'This device cannot find enough free resources that'
          str << ' it can use.'
          str
        when 13
          "Windows cannot verify this device's resources."
        when 14
          str = 'This device cannot work properly until you restart'
          str << ' your computer.'
          str
        when 15
          str = 'This device is not working properly because there is'
          str << ' probably a re-enumeration problem.'
          str
        when 16
          str = 'Windows cannot identify all the resources this device '
          str << ' uses.'
          str
        when 17
          'This device is asking for an unknown resource type.'
        when 18
          'Reinstall the drivers for this device.'
        when 19
          'Failure using the VXD loader.'
        when 20
          'Your registry might be corrupted.'
        when 21
          str = 'System failure: try changing the driver for this device.'
          str << ' If that does not work, see your hardware documentation.'
          str << ' Windows is removing this device.'
          str
        when 22
          'This device is disabled.'
        when 23
          str = 'System failure: try changing the driver for this device.'
          str << "If that doesn't work, see your hardware documentation."
          str
        when 24
          str = 'This device is not present, not working properly, or'
          str << ' does not have all its drivers installed.'
          str
        when 25, 26
          'Windows is still setting up this device.'
        when 27
          'This device does not have valid log configuration.'
        when 28
          'The drivers for this device are not installed.'
        when 29
          str = 'This device is disabled because the firmware of the'
          str << ' device did not give it the required resources.'
          str
        when 30
          str = 'This device is using an Interrupt Request (IRQ)'
          str << ' resource that another device is using.'
          str
        when 31
          str = 'This device is not working properly because Windows'
          str << ' cannot load the drivers required for this device'
          str
      end
    end

    private_class_method :get_cmec

    # Convert an cpu architecture number to a string
    def self.get_cpu_arch(num)
      case num
        when 0
          'x86'
        when 1
          'MIPS'
        when 2
          'Alpha'
        when 3
          'PowerPC'
        when 6
          'IA64'
        when 9
          'x64'
      end
    end

    private_class_method :get_cpu_arch

    # convert an Availability number into a string
    def self.get_availability(num)
      case num
        when 1
          'Other'
        when 2
          'Unknown'
        when 3
          'Running'
        when 4
          'Warning'
        when 5
          'In Test'
        when 6
          'Not Applicable'
        when 7
          'Power Off'
        when 8
          'Off Line'
        when 9
          'Off Duty'
        when 10
          'Degraded'
        when 11
          'Not Installed'
        when 12
          'Install Error'
        when 13
          'Power Save - Unknown'
        when 14
          'Power Save - Low Power Mode'
        when 15
          'Power Save - Standby'
        when 16
          'Power Cycle'
        when 17
          'Power Save - Warning'
        when 18
          'Paused'
        when 19
          'Not Ready'
        when 20
          'Not Configured'
        when 21
          'Quiesced'
      end
    end

    private_class_method :get_availability

    # convert CpuStatus to a string form.  Note that values 5 and 6 are
    # skipped because they're reserved.
    def self.get_status(num)
      case num
        when 0
          'Unknown'
        when 1
          'Enabled'
        when 2
          'Disabled by User via BIOS Setup'
        when 3
          'Disabled By BIOS (POST Error)'
        when 4
          'Idle'
        when 7
          'Other'
      end
    end

    private_class_method :get_status

    # Convert a family number into the equivalent string
    #
    # NOTE: This could be out of date as new data is added occasionally.
    # If there's a nicer way to do this, please send a PR my way.
    #
    def self.get_family(num)
      case num
        when 1
          'Other'
        when 2
          'Unknown'
        when 3
          '8086'
        when 4
          '80286'
        when 5
          '80386'
        when 6
          '80486'
        when 7
          '8087'
        when 8
          '80287'
        when 9
          '80387'
        when 10
          '80487'
        when 11
          'Pentium'
        when 12
          'Pentium Pro'
        when 13
          'Pentium II'
        when 14
          'Pentium with MMX'
        when 15
          'Celeron'
        when 16
          'Pentium II Xeon'
        when 17
          'Pentium III'
        when 18
          'M1'
        when 19
          'M2'
        when 24
          'K5'
        when 25
          'K6'
        when 26
          'K6-2'
        when 27
          'K6-3'
        when 28
          'AMD Athlon'
        when 29
          'AMD Duron'
        when 30
          'AMD2900'
        when 31
          'K6-2+'
        when 32
          'Power PC'
        when 33
          'Power 601'
        when 34
          'Power 603'
        when 35
          'Power 603+'
        when 36
          'Power 604'
        when 37
          'Power 620'
        when 38
          'Power X704'
        when 39
          'Power 750'
        when 48
          'Alpha'
        when 49
          'Alpha 21064'
        when 50
          'Alpha 21066'
        when 51
          'Alpha 21164'
        when 52
          'Alpha 21164PC'
        when 53
          'Alpha 21164a'
        when 54
          'Alpha 21264'
        when 55
          'Alpha 21364'
        when 64
          'MIPS'
        when 65
          'MIPS R4000'
        when 66
          'MIPS R4200'
        when 67
          'MIPS R4400'
        when 68
          'MIPS R4600'
        when 69
          'MIPS R10000'
        when 80
          'SPARC'
        when 81
          'SuperSPARC'
        when 82
          'microSPARC II'
        when 83
          'microSPARC IIep'
        when 84
          'UltraSPARC'
        when 85
          'UltraSPARC II'
        when 86
          'UltraSPARC IIi'
        when 87
          'UltraSPARC III'
        when 88
          'UltraSPARC IIIi'
        when 96
          '68040'
        when 97
          '68xxx'
        when 98
          '68000'
        when 99
          '68010'
        when 100
          '68020'
        when 101
          '68030'
        when 112
          'Hobbit'
        when 120
          'Crusoe TM5000'
        when 121
          'Crusoe TM3000'
        when 128
          'Weitek'
        when 130
          'Itanium'
        when 131
          'AMD Athlon 64'
        when 132
          'AMD Opteron'
        when 133
          'AMD Sempron'
        when 134
          'AMD Turion 64 Mobile'
        when 135
          'AMD Opteron Dual-Core'
        when 136
          'AMD Athlon 64 X2 Dual-Core'
        when 137
          'AMD Turion 64 X2 Mobile'
        when 138
          'AMD Opteron Quad-Core'
        when 139
          'AMD Opteron Third Generation'
        when 140
          'AMD Phenom FX Quad-Core'
        when 141
          'AMD Phenom X4 Quad-Core'
        when 142
          'AMD Phenom X2 Dual-Core'
        when 143
          'AMD Athlon X2 Dual-Core'
        when 144
          'PA-RISC'
        when 145
          'PA-RISC 8500'
        when 146
          'PA-RISC 8000'
        when 147
          'PA-RISC 7300LC'
        when 148
          'PA-RISC 7200'
        when 149
          'PA-RISC 7100LC'
        when 150
          'PA-RISC 7100'
        when 160
          'V30'
        when 161
          'Intel Xeon 3200 Quad-Core'
        when 162
          'Intel Xeon 3000 Dual-Core'
        when 163
          'Intel Xeon 5300 Quad-Core'
        when 164
          'Intel Xeon 5100 Dual-Core'
        when 165
          'Intel Xeon 5000 Dual-Core'
        when 166
          'Intel Xeon LV Dual-Core'
        when 167
          'Intel Xeon ULV Dual-Core'
        when 168
          'Intel Xeon 7100 Dual-Core'
        when 169
          'Intel Xeon 5400 Quad-Core'
        when 170
          'Intel Xeon Quad-Core'
        when 171
          'Intel Xeon 5200 Dual-Core'
        when 172
          'Intel Xeon 7200 Dual-Core'
        when 173
          'Intel Xeon 7300 Quad-Core'
        when 174
          'Intel Xeon 7400 Quad-Core'
        when 175
          'Intel Xeon 7400 Multi-Core'
        when 176
          'Pentium III Xeon'
        when 177
          'Pentium III with SpeedStep'
        when 178
          'Pentium 4'
        when 179
          'Intel Xeon'
        when 180
          'AS400'
        when 181
          'Intel Xeon MP'
        when 182
          'AMD Athlon XP'
        when 183
          'AMD Athlon MP'
        when 184
          'Intel Itanium 2'
        when 185
          'Intel Pentium M'
        when 186
          'Intel Celeron D'
        when 187
          'Intel Pentium D'
        when 188
          'Intel Pentium Extreme Edition'
        when 189
          'Intel Core Solo'
        when 190
          'K7'
        when 191
          'Intel Core2 Duo'
        when 192
          'Intel Core2 Solo'
        when 193
          'Intel Core2 Extreme'
        when 194
          'Intel Core2 Quad'
        when 195
          'Intel Core2 Extreme Mobile'
        when 196
          'Intel Core2 Duo Mobile'
        when 197
          'Intel Core2 Solo Mobile'
        when 198
          'Intel Core i7 Mobile'
        when 199
          'Intel Celeron Dual-Core'
        when 200
          'zSeries S/390'
        when 201
          'ESA/390 G4'
        when 202
          'ESA/390 G5'
        when 203
          'ESA/390 G6'
        when 204
          'z/Architectur'
        when 205
          'Intel Core i5'
        when 206
          'Intel Core i3'
        when 210
          'VIA C7-M'
        when 211
          'VIA C7-D'
        when 212
          'VIA C7'
        when 213
          'VIA Eden'
        when 214
          'Intel Xeon Multi-Core'
        when 215
          'Intel Xeon 3xxx Dual-Core'
        when 216
          'Intel Xeon 3xxx Quad-Core'
        when 217
          'VIA Nano'
        when 218
          'Intel Xeon 5xxx Dual-Core'
        when 219
          'Intel Xeon 5xxx Quad-Core'
        when 221
          'Intel Xeon 7xxx Dual-Core'
        when 222
          'Intel Xeon 7xxx Quad-Core'
        when 223
          'Intel Xeon 7xxx Multi-Core'
        when 224
          'Intel Xeon 3400 Multi-Core'
        when 230
          'AMD Opteron Embedded Quad-Core'
        when 231
          'AMD Phenom Triple-Core'
        when 232
          'AMD Turion Ultra Dual-Core Mobile'
        when 233
          'AMD Turion Dual-Core Mobile'
        when 234
          'AMD Athlon Dual-Core'
        when 235
          'AMD Sempron SI'
        when 236
          'AMD Phenom II'
        when 237
          'AMD Athlon II'
        when 238
          'AMD Opteron Six-Core'
        when 239
          'AMD Sempron M'
        when 250
          'i860'
        when 251
          'i960'
        when 260
          'SH-3'
        when 261
          'SH-4'
        when 280
          'ARM'
        when 281
          'StrongARM'
        when 300
          '6x86'
        when 301
          'MediaGX'
        when 302
          'MII'
        when 320
          'WinChip'
        when 350
          'DSP'
        when 500
          'Video'
      end
    end

    private_class_method :get_family

    # Convert power management capabilities number to its equivalent string
    def self.get_pmc(num)
      case num
        when 0
          'Unknown'
        when 1
          'Not Supported'
        when 2
          'Disabled'
        when 3
          'Enabled'
        when 4
          'Power Saving Modes Entered Automatically'
        when 5
          'Power State Settable'
        when 6
          'Power Cycling Supported'
        when 7
          'Timed Power On Supported'
      end
    end

    private_class_method :get_pmc

    # Convert a processor type into its equivalent string
    def self.get_processor_type(num)
      case num
        when 1
          'Other'
        when 2
          'Unknown'
        when 3
          'Central Processor'
        when 4
          'Math Processor'
        when 5
          'DSP Processor'
        when 6
          'Video Processor'
      end
    end

    private_class_method :get_processor_type

    # Convert an upgrade method into its equivalent string
    def self.get_upgrade_method(num)
      case num
        when 1
          'Other'
        when 2
          'Unknown'
        when 3
          'Daughter Board'
        when 4
          'ZIF Socket'
        when 5
          'Replacement/Piggy Back'
        when 6
          'None'
        when 7
          'LIF Socket'
        when 8
          'Slot 1'
        when 9
          'Slot 2'
        when 10
          '370 Pin Socket'
        when 11
          'Slot A'
        when 12
          'Slot M'
      end
    end

    private_class_method :get_upgrade_method

    # Convert return values to voltage cap values (floats)
    def self.get_voltage_caps(num)
      case num
        when 1
          5.0
        when 2
          3.3
        when 4
          2.9
      end
    end

    private_class_method :get_voltage_caps
  end
end
