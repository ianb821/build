#!/usr/bin/perl

################################################
#
#  build.pl written by Ian Burns 06/2013
#  build.pl is an automated build system
#  replacement for 'make'.  The idea is
#  to simplify the instructions file and
#  provide built in support for commonly
#  used functions like clean and tar.
#  For an example instruction file, called 
#  steps.build (instead of makefile) see:
#
#
#
#  For simple instructions enter 'build help' or
#  'build man'
#################################################

use v5.12;

my @lines;
my @words;
my $mainTargetLine = -1;
my $shouldRun = 0;
my $shouldTar = 0;
my $didCompileAnything = 0;

############################################
# SHOULD COMPILE
# Checks the timestamps of each of the
# dependecies and returns 1 if the file
# needs to be compiled, 0 if not
############################################
sub shouldCompile
{
   # used for checking last modification date of a file
   use File::stat;
   use Time::localtime;
   
   # make sure the file exits
   if (-e @words[0])
   {  
      my $timestamp = stat(@words[0])->mtime;
      
      for my $j (2...$#words)
      {
         my $fileTimeStamp = stat(@words[$j])->mtime;
         
         # if the file has been modified more recently than the target, 
         # recompile it
         if ($timestamp - $fileTimeStamp < 0)
         {
            return 1;
         }
      }
      return 0;
   }
   return 1;
}

############################################
# PERFORM ACTION
# Runs the commmand for a target
# CO   = g++ -c
# LINK = g++ -o
############################################
sub performAction
{
   $didCompileAnything = 1;
   my $command = @_[0] + 1;
   
   # get the words of the command line to check for shortcuts (CO, LINK...)
   my @commands = split(" " , @lines[$command]);
   my $compile;

   
   # COC is short for clang++ -c
   if (@commands[0] eq "COC")
   {
      $compile = "clang++ -c @commands[1]";
      print $compile . "\n";
      system($compile);
   }
   
   # CO is short for g++ -c
   elsif (@commands[0] eq "CO")
   {
      
      $compile = "g++ -c @commands[1]";
      print $compile . "\n";
      system($compile);
   }
   
   # LINK is short for g++ -o, the target name is added automatically
   elsif (@commands[0] eq "LINK")
   {
      my @temp = split(" ", @lines[$command - 1]);
      my $name = @temp[0];
      $compile = "g++ -o $name ";
      for my $index (2 .. $#temp)
      {
         $compile = $compile . @temp[$index] . " ";
      }
      print $compile . "\n";
      system($compile);
   }
   
   # LINKC is the same as LINK, but uses clang
   elsif (@commands[0] eq "LINKC")
   {
      my @temp = split(" ", @lines[$command - 1]);
      my $name = @temp[0];
      $compile = "clang++ -o $name ";
      for my $index (2 .. $#temp)
      {
         $compile = $compile . @temp[$index] . " ";
      }
      print $compile . "\n";
      system($compile);
   }
   
   # If no shortcut is found, just send the command to the command line
   else
   {
      print @lines[$command];
      system(@lines[$command]);
   }
   
}

############################################
# FIND THE MAIN TARGET
# Finds the line containing the rules for
# the first found target
############################################
sub findTheMainTarget
{
   for my $index (0 .. $#_)
   {
      my $temp = @_[$index];
      my @tempWords = split(' ', $temp);
      
      if (@tempWords[1] eq "<d>")
      {
         $mainTargetLine = $index;
         return;
      }
   }
}

############################################
# FIND THE REQUESTED TARGET
# Finds the line containing the rules for
# the target put in at the command line
############################################
sub findTheRequestedTarget
{
   $mainTargetLine = -1;
   
   for my $index (0 .. $#_)
   {
      my $temp = @_[$index];
      my @tempWords = split(' ', $temp);
      
      if (@tempWords[0] eq @_[-1])
      {
         $mainTargetLine = $index;
         return;
      }
   }
}

############################################
# BUILD ALL
# Builds all targets in the steps.build
############################################
sub buildAll
{
   for my $index (reverse 0 .. $#_)
   {
      my @localWords = split(' ', @_[$index]);
      if (@localWords[1] eq "<d>")
      {
         performAction($index);
      }
   }
}


############################################
# CLEAN
# Cleans all existing files that are created
# by the steps.build file
############################################
sub clean
{
   # Get the possible tar name
   my $firstLine = @_[$mainTargetLine];
   my @firstWords = split(" ", $firstLine);
   (my $fileName = @firstWords[0]) =~ s/\.[^.]+$//;
   $fileName .= ".tar";

   my $cleanCommand = "rm ";
   
   foreach (@_)
   {
      my @localWords = split(' ', $_);
      if (@localWords[1] eq "<d>")
      {
         if (-e @localWords[0])
         {
            $cleanCommand .= @localWords[0] . " ";
         }
      }
   }
   
   if (-e $fileName)
      {
         $cleanCommand .= $fileName;
      }
   
   if ($cleanCommand ne "rm ")
   {
      print $cleanCommand . "\n";
      system($cleanCommand);
   }
   else
   {
      print "*** No files to be cleaned ***\n";
   }
   
}

############################################
# MAIN
# Main function handles command line input
############################################

# try and open the steps.build file
if ((open FILE, "steps.build") == 0)
{
   print "*** ERROR: No \'steps.build\' file found ***\n";
   exit(1);
}

# read in the lines of a file
while (<FILE>)
{
   push(@lines, $_);
}

close(FILE);


# find the first rule and store the index of the rule
findTheMainTarget(@lines);

if ($mainTargetLine == -1)
{
   print "*** ERROR: No rules found in steps.build file\n";
   exit(1);
}


# check to see if there were any arguements passed in at the command line, parse if so
if (@ARGV > 0)
{
   if (@ARGV[0] eq "clean")
   {
      clean(@lines);
      exit(1);
   }
   
   elsif (@ARGV[0] eq "tar")
   {
      # get main target name for the tar name
      my $firstLine = @lines[$mainTargetLine];
      my @firstWords = split(" ", $firstLine);
      (my $fileName = @firstWords[0]) =~ s/\.[^.]+$//;
      
      my $tarCommand = "tar -cf $fileName.tar *.h *.cpp steps.build";
      print $tarCommand . "\n";
      system($tarCommand);
      exit(1);
   }
   
   elsif (@ARGV[0] eq "help" || @ARGV[0] eq "man")
   {
      print "\nUsage:\n";
      print "\t\'build\'         - Builds the target according to the steps.build file\n";
      print "\t\'build clean\'   - Removes all .o files and the tar file if present\n";
      print "\t\'build tar\'     - Creates a tar with the .h, .cpp, and steps.build files\n";
      print "\t\'build and run\' - Builds the target and runs the output file\n";
      print "\t\'build and tar\' - Builds then tars the .h, .cpp, and steps.build files\n";
      print "\t\'build all\'     - Builds all files in the steps.build file\n\n";
      exit(1);
      
   }
   
   # checks for the 'and' modifier
   elsif (@ARGV[0] eq "and")
   {
      if (@ARGV[1] eq "")
      {
         print "*** ERROR: Please specify a command after \'and\' ***\n";
         exit(1);
      }
      elsif (@ARGV[1] eq "tar")
      {
         $shouldTar = 1;
      }
      elsif (@ARGV[1] eq "run")
      {
         $shouldRun = 1;
      }
      else
      {
         print "*** ERROR: \'@ARGV[1]\' is not valid with the \'and\' modifier *** \n";
         exit(1);
      }
   }
   elsif (@ARGV[0] eq "all")
   {
      buildAll(@lines);
      exit(1);
   }
   else
   {
      findTheRequestedTarget(@lines, @ARGV[0]);

      if ($mainTargetLine == -1)
      {
         print "*** ERROR: \'@ARGV[0]\' is not a recongnized command *** \n";
         exit(1);
      }
   }
}

# checks to see what object files need to be created/recompiled
my @dependeciesToCheck = split(' ', @lines[$mainTargetLine]);
my @linesForRules;
my $foundRule;

for my $i (2 .. $#dependeciesToCheck)
{
   $foundRule = 0;
   
   for my $j ($mainTargetLine + 2 .. $#lines)
   {
      @words = split(' ', @lines[$j]);
      
      if (@words[0] eq @dependeciesToCheck[$i])
      {
         push(@linesForRules, $j);
         $foundRule = 1;
      }
   }
   
   if ($foundRule == 0)
   {
      print "*** ERROR: rule for \'@dependeciesToCheck[$i]\' not found ***\n";
      exit(1);
   }
}

# compile the dependency files
foreach (@linesForRules)
{
   @words = split(' ', @lines[$_]);
   
   if (shouldCompile(@lines[$_]) == 1)
   {
      performAction($_);
   }
}

# checks to see if the main target needs to recompiled
@words = split(' ', @lines[$mainTargetLine]);

if (@words[1] eq "<d>")
{
   if (shouldCompile(@words) != 0)
   {
      performAction($mainTargetLine);
   }
}

# informs the user if not changes were made
if ($didCompileAnything == 0)
{
   my $firstLine = @lines[$mainTargetLine];
   my @firstWords = split(' ', $firstLine);
   print "*** All files are up to date, \'$firstWords[0]\' is unchanged ***\n";
   
}

# checks to see if the file should be run after compiling
if ($shouldRun != 0)
{
   
   my $firstLine = @lines[$mainTargetLine];
   my @firstWords = split(' ', $firstLine);
   
   print "./$firstWords[0]\n";
   system("./$firstWords[0]");
}

# checks to see if the files should be tarred(sp?)
if ($shouldTar != 0)
{
   my $firstLine = @lines[$mainTargetLine];
   my @firstWords = split(" ", $firstLine);
   (my $fileName = @firstWords[0]) =~ s/\.[^.]+$//;
   
   my $tarCommand = "tar -cf $fileName.tar *.h *.cpp steps.build";
   print $tarCommand . "\n";
   system($tarCommand);
}


