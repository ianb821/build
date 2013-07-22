#Build

build.pl is a simple automated build system replacement for 'make'. The idea is to 
simplify the instructions file and provide built in support for commonly used functions, 
some of those include:

  * 'build' to build the main target in the instruction file
  * 'build clean' command built in
  * 'build tar' or 'build and tar' command to tar all project files and the instruction file (build and tar rebuilds before running the tar command)
  * 'build and run' to build then run the program
  * 'build all' to build all targets in the instruction file
  * Shortcut syntax for common commands:
    * 'CO FILENAME' (compile object) for 'g++ -c FILENAME'
    * 'COC FILENAME' for 'clang++ -c FILENAME'
    * 'LINK' to build the final output file and link all .o files together with gcc (FILENAME isn't included because it is taken from the target name provided)
    * 'LINKC' same as LINK, but uses clang
    

With build.pl, the instruction file must be named steps.build, and follows a similar 
format to 'makefile'. For an example instruction file, called see the included 
steps.build file.

For a simple instructions and commands use 'build help' or 'build man'.


#License - MIT
 	Copyright (C) 2013 Ian Burns

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated	
		documentation files (the "Software"), to deal in the Software without restriction, including without limitation
		the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
		to permit persons to whom the Software is furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all copies or substantial portions of 
		the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
		THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
		SOFTWARE.
