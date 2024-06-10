## 1.1.0 - 9-Jun-2024
* Removed Solaris support.
* Added DragonflyBSD support.
* Fixed example task.
* Made some constants private in the generic Unix code that should
  have been private.
* The architecture method on Linux will now interpret values 4, 5
  and 15. If it's not any of those values it will return 'Unknown'.

## 1.0.6 - 12-Aug-2022
* The Sys::CPU.model method will now return "ARM" for machines using an
  ARM-based processor instead of "Unknown".

## 1.0.5 - 10-Aug-2022
* Updated the cpu detection handling for Mac M1 systems. Thanks go to
  Julien W for the spot.

## 1.0.4 - 10-Jun-2022
* The OSX code for the CPU.freq method was updated for arm64 systems.
* Some refactoring to the specs and uses shared examples now.
* Now makes the new method a private class method. The constructor was never
  meant to be used with this library, so now it's explicitly forbidden.
* Added rubocop and rubocop-rspec as development dependencies, as well as
  a rubocop rake task, and applied some suggested changes.
* Fixed the global Gemfile source issue. Just use the gemspec.
* Added some new cpu families for Windows.
* Added a respond_to_missing? method to the Linux version since it uses
  method_missing.
* The MS Windows version now assumes Ruby 2.0 or later.

## 1.0.3 - 28-Jan-2021
* The code for OSX was split out into its own source file. This was partly for
  ease of maintenance, but also because there was confusion with the
  processor_info function. The original function was only aimed at Solaris, but
  it turns out OSX has its own, different implementation. This caused segfaults.

## 1.0.2 - 25-Jan-2021
* Fixed issues where things that were meant to be private weren't actually private.

## 1.0.1 - 20-Dec-2020
* Switched from rdoc to markdown.

## 1.0.0 - 23-Oct-2020
* Fixed a bug in the Windows version where the attempt to convert the ConfigManagerErrorCode
  to a string was busted. Coincidentally, this also exposed a core bug in JRuby (see PR #6443).
  Thanks go to G. Gibson for reporting the issue.
* Switched the tests from test-unit to rspec.

## 0.9.0 - 12-May-2020
* Added explicit freq, architecture, num_cpu and model methods to the Linux
  version in an effort to create a common interface across platforms.
* Modified the Linux version so that method_missing will raise a NoMethodError
  if you try to call access an attribute that doesn't exist.
* Some updates to the Linux tests.

## 0.8.3 - 18-Mar-2020
* Properly include a LICENSE file as per the Apache-2.0 license.

## 0.8.2 - 14-Jan-2020
* Added explicit .rdoc extension to README, CHANGES and MANIFEST files.
* Fixed license name in README.

## 0.8.1 - 4-Nov-2018
* Added metadata to the gemspec.
* Fixed missing hyphen in license name.

## 0.8.0 - 17-Oct-2018
* Switched license to Apache 2.0.
* Updated documentation for the cpu_stats method on Linux.
* The VERSION constant is now frozen.
* Now uses require_relative internally where needed.

## 0.7.2 - 5-Sep-2015
* Replaced a global array with a constant in the Linux version. Thanks go
  to Yorick Peterse for the patch.
* Added method comments back to the Unix version.
* Added a sys-cpu.rb stub file for your convenience.
* This gem is now signed.

## 0.7.1 - 2-May-2013
* Added a workaround for a win32ole bug in the Windows version.
* Reorganized code so that there is now a single gem rather than three
  separate platform gems.
* Updated test-unit dependency which let me simplify the test files a bit.

## 0.7.0 - 14-Dec-2011
* Code base now uses FFI. However, HP-UX is not currently supported.
  HP-UX users should continue to use the 0.6.x version. Note that
  the code base remains unchanged on Linux and Windows.
* The cpu_type method has been replaced with the architecture method
  on Solaris to keep the interface more in line with other platforms.
* The type method has been changed to cpu_type on Windows.
* Some Rakefile and test suite updates.

## 0.6.4 - 27-Sep-2011
* The CPU.freq method now works on OSX.
* The CPU.model method on OSX has been altered. Previously it
  returned the machine model. However, the information is limited.
* Fixed a couple unused variable warnings for the BSD/OSX code.
* The Linux and Windows gems now have a 'universal' architecture.
* Refactored the clean task in the Rakefile.

## 0.6.3 - 9-Oct-2010
* Fixed a bug in the install.rb file and refactored it a bit. Thanks go
  to Di-an Jan for the spot. Note, however, that this file will eventually
  be removed and/or integrated into the Linux source file.
* Fixed the example Rake task, and refactored some of the other tasks.
* Fixed and updated the CPU.architecture method on MS Windows to handle IA64
  and x64 architectures.

## 0.6.2 - 1-Jan-2010
* Fixed a bug in the cpu_freq function (which would only be noticed on
  certain platforms in cases where the CPU.freq method failed). Thanks
  go to Edho P Arief for the spot.
* Explicitly add sys/param.h on OpenBSD, and default to the HW_MODEL mib
  because HW_MACHINE does not exist. Thanks go to Edho P Arief for the patch.
* Updated my support notes. In short I will support 1.8.6 and 1.9.x. I will
  not support any 1.8.x branch later than 1.8.6.
* Removed redundant information in the various .txt files that is already
  covered in the README file.
* Test files renamed.
* Added test-unit 2.x as a development dependency.

## 0.6.1 - 4-Jan-2009
* Fix for OS X 10.5.x. Thanks go to Victor Costan for the spot and the patch.
* Updated the gemspec and some other minor changes.
* On MS Windows the impersonation level is now explicitly set to 'impersonate'
  to avoid issues where systems might be using an older version of WMI.

## 0.6.0 - 26-Apr-2007
* Added support for most BSD flavors, including OS X. The freebsd.c file is
  now just bsd.c.
* The CPU.type method for Solaris has been changed to CPU.cpu_type to avoid
  conflicting with the Object.type method.
* Added a Rakefile. There are now tasks for building, testing and installing,
  among other things. Run 'rake -T' to check your options.
* Many internal directory layout changes - C source files are now under the
  'ext' directory.
* Improved RDoc comments in the C source files.
* Changed CPUError to CPU::Error.

## 0.5.5 - 17-Nov-2006
* Fixed a bug in the Linux version where there could be a key but no
   associated value, causing a String#strip! call to fail.  Now the value is
   simply left at nil.
* Refactored the CPU.processors method on Linux, including the removal of '?'
  from the CPUStruct members for the boolean methods (Ruby doesn't like them).
* Minor tweaks and updates to the documentation, including the README.
* Modified the gemspec so that it sets the platform properly for Linux
  and Windows.

## 0.5.4 - 12-Jul-2006
* Added a gemspec (and a gem on RubyForge).
* The CPU.architecture method on HP-UX now returns nil if it cannot be
  determined instead of "Unknown" for consistency with the other
  platforms.
* Inlined the RDoc and made some minor cosmetic source code changes.

## 0.5.3 - 4-May-2006
* Fixed in a bug in the Solaris version where CPU.load_avg returned bad values
  when compiled in 64 bit mode.  Thanks go to James Hranicky for the spot and
  both James Hranicky and Peter Tribble (via comp.unix.solaris) for patches.
* Made some modifications to the test suite.  You know longer need to know
  which test suite to run.  All platforms now use 'ts_all.rb', which will run
  the appropriate test case behind the scenes.

## 0.5.2 - 24-Jun-2005
* Bug fixed on Linux where empty lines could cause problems.  This affected
  both the install.rb and linux.rb files, though it only seems to have been
  an issue on the 2.6+ kernel.
* Altered the behavior of the CPU.cpu_stats method on Linux.  Now, only the
  numbered cpu entries return associated data, unless the numberless entry
  is the only entry.
* Added a sample program for Linux under the 'examples' directory.

## 0.5.1 - 5-May-2005
* Fixed a potential bug in the FreeBSD version of CPU.model.
* Eliminated some warnings in the FreeBSD version.
* Moved examples directory to the toplevel package directory.
* Renamed and updated the sample scripts.
* Added a sample script for FreeBSD.
* Removed the INSTALL file.  That information is now included in the README.
* Made the CHANGES, README, and .txt files rdoc friendly.
* The dynamic documentation generation for Linux has been altered.  Anything
  relating to rd2 has been removed.  The doc file generated is now
  doc/linux.txt.
* Some $LOAD_PATH setup changes in the unit tests.

## 0.5.0 - 26-Jun-2004
* Now requires Ruby 1.8.0 or later.
* FreeBSD support added.
* Replaced 'CPUException' with 'CPUError'
* The MS Windows version has been completely revamped to use WMI instead of
  the C API.  Some method names have changed and some methods have been
  dropped entirely.  Please see the documentation for details.
* Corresponding documentation updates and test suite changes.
* Sample programs have been moved to doc/examples.
* Installation procedure somewhat revamped.
* No longer autogenerates test file.
* The .html files have been removed.  You can generate the html on your own
  if you like.

## 0.4.0 - 18-Sep-2003
* Added MS Windows support
* Changed some method names.  The "cpu" has been dropped from most method
  names.  See documentation for details.
* The state() and freq() methods (where supported) now assume a default 
  value of zero.
* More unit tests added.
* Fixed minor issue with test.rb for those without TestUnit installed.
* Fixed issue with linux.rb file being auto-installed on non-Linux platforms.
* Minor API change for the load_avg() method on HP-UX.  It now accepts a
  CPU number as an argument.

## 0.3.1 - 16-Jul-2003
* Fixed a bug in the Solaris version that was using up and not
  freeing file descriptors.
* Added html doc for Solaris under doc directory.
* Minor changes to test_hpux.rb and test_sunos.rb
* Minor README changes.

## 0.3.0 - 30-Jun-2003
* Added HP-UX support
* Removed the VERSION class method.  Use the constant instead
* Changed license to "Artistic"
* Moved version info into its own file for convenience
* Some minor mods to the test suites
* Modified extconf.rb, moving some of the dynamic test generation
  into separate files

## 0.2.2 - 25-Mar-2003
* fpu_type and cpu_type now return nil if not found (Solaris)
* CPUException is now a direct subclass of StandardError
* Modified extconf.rb script
* Minor doc updates
* Added another test to the solaris test suite
* Important note added to INSTALL file

## 0.2.1 - 12-Mar-2003
* Added the cpu_stats() class method for Linux, which contains the
  data from the 'cpu' lines of /proc/stat
* Minor fix for extconf.rb (thanks Michael Granger)
* Some tests added to Linux test suite
* MANIFEST correction

## 0.2.0 - 13-Feb-2003
* Linux support added (pure Ruby only)
* Many changes to extconf.rb to support Linux version
* sys-uname prerequisite dropped
* rd2 documentation now kept separate from source

## 0.1.0 - 3-Feb-2003
* Initial release
* Currently supports Solaris (only)
