build.pl is a simple automated build system replacement for 'make'. The idea is to 
simplify the instructions file and provide built in support for commonly used functions, 
some of those include:

  -'build' to build the main target in the instruction file
  -'build clean' command built in
  -'build tar' or 'build and tar' command to tar all project files and the instruction 
  	file (build and tar rebuilds before running the tar command)
  -'build and run' to build then run the program
  -'build all' to build all targets in the instruction file
  -Shortcut syntax for common commands:
    -'CO FILENAME' (compile object) for 'g++ -c FILENAME'
    -'COC FILENAME' for 'clang++ -c FILENAME'
    -'LINK' to build the final output file and link all .o files together with gcc 
    (FILENAME isn't included because it is taken from the target name provided)
    -'LINKC' same as LINK, but uses clang
    

With build.pl, the instruction file must be named steps.build, and follows a similar 
format to 'makefile'. For an example instruction file, called see the included 
steps.build file.

For a simple instructions and commands use 'build help' or 'build man'.
