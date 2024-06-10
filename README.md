[![Ruby](https://github.com/djberg96/sys-cpu/actions/workflows/ruby.yml/badge.svg)](https://github.com/djberg96/sys-cpu/actions/workflows/ruby.yml)

* Linux
* Windows
* OSX
* DragonflyBSD

## Description
A Ruby interface for getting cpu information.

## Installation
`gem install sys-cpu`

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/sys-cpu/main/certs/djberg96_pub.pem)`

## Notes
### Solaris
There is no `processors` iterative method for multi-cpu systems. I was going to
add this originally, but since Solaris is basically dead at this point I've
dropped the idea.
   
### OS X
The `CPU.model` method returns very limited information. I do not yet know
how to get more detailed information.

### Linux
This is pure Ruby. This version reads information out of /proc/cpuinfo and
/proc/loadavg, so if /proc isn't mounted it won't work.

The key-value information in /proc/cpuinfo is stored internally (i.e. in
memory) as an array of hashes when you first `require` this package. This
overhead is exceptionally minimal, given that your average cpuinfo file
contains less than 1k of text (and I don't store whitespace or newlines).

The text documentation for Linux is dynamically generated during the
build process because the fields vary depending on your setup. So, don't
look at it until *after* you've installed it. You will see a doc/linux.txt
file after you run `rake install` (via install.rb).

### HP-UX
Unlike other platforms, you can get load averages for an individual cpu in
multi-cpu systems. See documentation for more details.

Note that version 0.7.x and later will not work on HP-UX because of the
switch to FFI and the lack of a testing platform. However, version 0.6.x
will work just fine.

### MS Windows
This is a pure Ruby implementation using the win32ole package + WMI. The C
version has been scrapped. 

As of version 0.5.0, the `CPU.usage` method has been removed in favor of the
`CPU.load_avg` method. This does not (currently) use a perf counter, so there
is no longer any delay. Also, the `processors` method has been added and the
`supported` method has been dropped. See the documentation for other changes.
   
## Acknowledgements
Thanks go to the MPlayer team for some source code that helped me on
certain versions of FreeBSD in the original C version.

## Known Bugs
None that I'm aware of. Please report bugs on the project page at:

https://github.com/djberg96/sys-cpu

## Future Plans
* Add iterative `CPU.processors` method.
* Add more information in general, such as what `prtdiag` shows.

## License
Apache-2.0

## Copyright
(C) 2003-2024 Daniel J. Berger, All Rights Reserved

## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author
Daniel J. Berger
