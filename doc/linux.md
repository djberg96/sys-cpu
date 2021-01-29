## Description
Sys::CPU - An interface for various cpu statistics

## Synopsis
```ruby
require 'sys-cpu' # Or "sys/cpu"

Sys::CPU.processors{ |cs|
  cs.members.each{ |m|
    puts "#{m}: " + cs[m].to_s
  }
}

Sys::CPU.bogomips(1) # -> returns bogomips for cpu #2
```

## Notes

Portions of this documentation were built dynamically.

## Constants

VERSION

Returns the current version number for this library as a string.

## Class Methods
`CPU.load_avg`

Returns an array of three floats indicating the 1, 5 and 15 minute load average.

`CPU.cpu_stats`

Returns a hash, with the cpu number as the key and an array as the value.
The array contains the number of seconds that the system spent in
user mode, user mode with low priority (nice), system mode, and the
idle task, respectively, for that cpu.

`CPU.processors{ |cpu_struct| ... }`

Calls the block for each processor on your system, yielding a `CPUStruct` to the block.

The exact members of the `CPUStruct` are the same as the singleton method names, except
for `Sys::CPU.processors` (although you may optionally omit the "?" when referring to a
struct member). These were determined when you installed this library because they
vary from one chip architecture to another.
