# Human-readable mappings for ARM CPU fields
# Add more mappings as needed for your use case
module Sys
  module LinuxCpuHumanReadable
    IMPLEMENTER = {
      '0x41' => 'ARM',
      '0x42' => 'Broadcom',
      '0x43' => 'Cavium',
      '0x44' => 'Digital Equipment Corporation',
      '0x4e' => 'NVIDIA',
      '0x50' => 'APM',
      '0x51' => 'Qualcomm',
      '0x56' => 'Marvell',
      '0x61' => 'SiFive',
      '0x69' => 'Intel',
    }

    ARCHITECTURE = {
      '7' => 'ARMv7',
      '8' => 'ARMv8',
      '9' => 'ARMv9',
    }

    # Add more mappings for VARIANT, PART, REVISION if needed
  end
end