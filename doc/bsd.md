## Description

A Ruby interface for various cpu statistics
   
## Synopsis
```ruby
  require 'sys/cpu' # or 'sys-cpu'

  # BSD and OS X
  puts "Architecture: " + Sys::CPU.architecture
  puts "Machine: " + Sys::CPU.machine
  puts "Mhz: " + Sys::CPU.cpu_freq.to_s
  puts "Number of cpu's on this system: " + Sys::CPU.num_cpu.to_s
  puts "CPU model: " + Sys::CPU.model
  puts "Load averages: " + Sys::CPU.load_avg.join(", ")
```
   
## Constants
`VERSION`

Returns the current version number for this library.
    
## Singleton Methods

`CPU.architecture`

Returns the cpu's architecture, e.g. "x86_64".

`CPU.freq`

Returns an integer indicating the speed (i.e. frequency in Mhz) of
the cpu.
   
`CPU.load_avg`

Returns an array of three floats indicating the 1, 5 and 15 minute load
average.

`CPU.machine`

Returns the class of cpu (probably identical to the architecture).

`CPU.model`

Returns a string indicating the cpu model, e.g. "Intel".
    
`CPU.num_cpu`

Returns an integer indicating the number of cpu's on the system.
    
## Error Classes
`CPU::Error < StandardError`

Raised is response to internal function errors, usually relating to an
invalid cpu number.
    
## More Information
See the `README.md` file for more information.
