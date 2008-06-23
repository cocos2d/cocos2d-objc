BUILDING:

  OS X: There is an included XCode project file for building the
  static library and demo application. Alteratively you could use the
  CMake files.

  UNIX: A forum user was kind enough to make a set of CMake files for
  Chipmunk. This will require you to have CMake installed. To build
  run 'cmake .' then 'make'. This should build a dynamic library, a
  static library, and the demo application.

  Windows: There is an included MSVC project for building the library
  and demo application.

  Ruby: I maintain a Ruby extension for Chipmunk. To build it, run
  'ruby extconf.rb' then 'make' from inside the ruby directory.

GETTING STARTED:
	
  A good place to start is with the MoonBuggy tutorial that is
  available on the main Chipmunk page.
  http://wiki.slembcke.net/main/published/Chipmunk

FORUM:

  http://www.slembcke.net/forums

CONTACT:

  slembcke@gmail.com (also on Google Talk)

CHANGES SINCE RELEASE 3:

  * Rational versioning scheme: (major.minor.build) Small changes
    increment the build number. Significant changes that don't affect
    backwards compatibility increment the minor number. Major changes
    that will break backwards compatibility will increment the major
    number.

  * Optimizations: Speed increases of 5-10% should be common.

  * Groove Joint: Similar to a pivot joint, but one of the anchors is
    on a linear slide instead of being fixed.

  * Comments/cleanup. The code should be much more readable now.

  * Official build paths for working on Linux and MSVC.
