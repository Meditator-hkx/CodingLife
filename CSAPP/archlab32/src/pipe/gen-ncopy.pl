#!/usr/bin/perl
#!/usr/local/bin/perl

##################################################
# Generate different versions of ncopy program.
# This program can generate versions using a variety of different
# optimizations.  
#
# The baseline optimizations replace the conditional jumping in the given
# code to use conditional moves.  It also avoids the load/use hazard
# in the given code, and it makes use of the iaddl instruction.
# These changes reduce the average CPE to 12.52.
# 
# It implements loop unrolling, with the amount of unrolling set
# by the -u commandline parameter.  The standard version then
# single-steps through any remaining elements, as is described in
# CS:APP2e Section 5.8.  The best performance is obtained by unrolling
# by a factor of 6, giving an average CPE of 10.01.
#
# Various alternative methods of handling the extra elements from
# loop unrolling are implemented.  Let r = n mod u be the number of
# elements that need to be handled outside of the main loop.
# 
# -c   Cascading powers of two
# Considers the binary representation of r, with blocks of code
# handling the copying for different powers of two.  Best performance
# obtained when unrolling by 8.  Gives average CPE of 9.85.
#
# -j   Jump into completion code
# Code finishes with a block of u-1 copies.  Jumps to point where
# remaining r copies take place.  The standard version computes this
# position by recognizing that the code to copy each element is 24 bytes
# long.  With the -t option, the code uses a jump table.
# Best performance is use a jump table and unroll by 17, giving
# an average CPE of 9.27.  (The degree of unrolling is limited
# by the 1000 byte limit.)
#
# -e   Early fixup
# At the beginning of the function, the code jumps into the main loop
# to a point where r copies will take place.  Optionally uses jump
# table to determine jump target.  This code version can only unroll
# by powers of two.  Best performance is to use a jump table and unroll by
# 32, giving an average CPE of 9.75.
##################################################


$tabwidth = 8;
$commentstart = 32;

# Print formatted line of assembly code, with comment in appropriate spot
sub aline
{
  local ($cmd, $cmt) = @_;
  local $cpos = length($cmd);
  # See if cmd is a label
  if (!($cmd =~ ":")) {
    print "\t";
    $cpos += $tabwidth;
  }
  print $cmd;
  if (length($cmt) > 0) {
    while ($cpos < $commentstart) {
      print " ";
      $cpos ++;
    }
    print "# ";
    print $cmt;
  }
  print "\n";
}

sub cline
{
   local ($cmt) = @_;
   print "# $cmt\n";
}

sub bline
{
  print "\n";
}

sub ecpy
{
  local ($i) = @_;
  local $i4 = $i * 4;  
  aline("mrmovl $i4(%ebx), %esi", "read val from src+$i");
  aline("rrmovl %eax, %edi", "Copy count");
  aline("iaddl \$1, %edi", "count+1");
  aline("andl %esi, %esi", "Test val");
  aline("cmovg %edi, %eax", "If val > 0, count = count+1");
  aline("rmmovl %esi, $i4(%ecx)", "Store val at dst+$i");
}

# gen-ncopy Program to generate different versions of copy routine 

use Getopt::Std;

# What unrolling factor should be used.
$unroll = 1;
$usespecial = 0;
$usecascade = 0;
$usejump = 0;
$earlyfixup = 0;
$usetable = 0;

getopts('hu:cjset');

if ($opt_h) {
    print STDERR "Usage $argv[0] [-h] [-u U] ([-c|-j]) [-s]\n";
    print STDERR "   -h      print help message\n";
    print STDERR "   -u U    set unrolling factor\n";
    print STDERR "   -c      use cascading powers of 2\n";
    print STDERR "   -j      use computed jump\n";
    print STDERR "   -e      Do early fixup\n";
    print STDERR "   -t      Use jump table\n";
    print STDERR "   -s      use special instruction\n";
    die "\n";
}

if ($opt_u) {
    $unroll = $opt_u;
}

if ($opt_c) {
  if ($unroll < 2) {
    print STDERR "Cannot cascade without unrolling\n";
    die "\n";
  }
  $usecascade = 1;
}

if ($opt_j) {
  if ($usecascade) {
    print STDERR "Can't use both jump and cascade\n";
    die "\n";
  }
  if ($unroll < 2) {
    print STDERR "Cannot use jumps without unrolling\n";
    die "\n";
  }
  $usejump = 1;
}

if ($opt_e) {
  if ($usecascade) {
    print STDERR "Can't use both early fixup and cascade\n";
    die "\n";
  }
  if ($unroll < 2) {
    print STDERR "Cannot use early fixup without unrolling\n";
    die "\n";
  }
  $earlyfixup = 1;
}

if ($opt_t) {
  $usetable = 1;
}

if ($opt_s) {
    $usespecial = 1;
}

# Determine if $unroll is a power of 2
$ispwr2 = 0;

$idx = 1;
while ($idx < $unroll) {
    $idx *= 2;
}
if ($idx == $unroll) {
    $ispwr2 = 1;
}

if ($earlyfixup && !$ispwr2) {
  die "Early fixup requires unrolling by power of 2\n";
}

cline("#################################################################");
cline("ncopy.ys - Copy a src block of len ints to dst.");
cline("Return the number of positive ints (>0) contained in src.");
cline(""); cline("Include your name and ID here."); cline("");
cline("Describe how and why you modified the baseline code.");
cline("This code unrolls the main loop by a factor of $unroll.");
if ($usecascade) {
  cline("It finishes the remaining elements by selectively copying");
  cline("blocks that ascending powers of 2");
} elsif ($usejump) {
  cline("It finishes by jumping to the appropriate position in a code");
  cline("sequence that copies the possible remaining elements");
} elsif($earlyfixup) {
  cline("It jumps partway into the initial loop based on the value");
  cline("of cnt mod $unroll");
}
cline("#################################################################");
bline();
cline("Do not modify this portion");
cline("Function prologue");
aline("ncopy:");
aline("pushl %ebp", "Save old frame pointer");
aline("rrmovl %esp,%ebp ", "Set up new frame pointer");
aline("pushl %esi ", "Save callee-save regs");
aline("pushl %ebx");
aline("pushl %edi");
aline("mrmovl 8(%ebp),%ebx", "src");
aline("mrmovl 12(%ebp),%ecx", "dst");
aline("mrmovl 16(%ebp),%edx", "len");
bline();
cline("#################################################################");
cline("You can modify this portion");
bline();

aline("xorl %eax,%eax", "count = 0");
if ($earlyfixup) {
  $um1 = $unroll-1;
  aline("irmovl \$$um1, %edi", "Mask for residue");
  aline("andl %edx, %edi", "residue = cnt mod $unroll");
  aline("irmovl \$$unroll, %esi");
  aline("subl %edi, %esi", "a = $unroll - residue");
  cline("Back up starting point of copy by a (between 1 and $unroll)");
  aline("addl %esi, %edx", "Increase len by a");
  aline("addl %esi, %esi", "2a");
  aline("addl %esi, %esi", "4a");
  aline("subl %esi, %ebx", "src-a");
  aline("subl %esi, %ecx", "dst-a");
  if ($usetable) {
    cline("Fetch starting point from jump table");
    aline("mrmovl JTab(%esi), %esi", "Get jump target");
  } else {
    cline("Compute offset into loop code by 24a");
    aline("addl %esi, %esi", "8a");
    aline("rrmovl %esi, %edi", "8a");
    aline("addl %edi, %edi", "16a");
    aline("addl %edi, %esi", "24a");
    aline("iaddl Loop, %esi", "Starting position for first loop");
  }
  aline("pushl %esi");
  aline("ret", "Jump to starting position");
} elsif ($unroll == 1) {
  aline("andl %edx,%edx", "Test len");
  aline("jle SkipLoop", "if <= 0, skip loop");
} else {
  aline("iaddl \$-$unroll, %edx", "lmu = len - $unroll");
  aline("jl SkipLoop", "If < 0, skip loop");
  bline();
}
cline("Main loop.  Copy $unroll elements per iteration");
aline("Loop:");

$u4 = $unroll*4;

for ($i = 0; $i < $unroll; $i++) {
  if ($earlyfixup) {
    aline("Copied$i:");
  }
  &ecpy($i);
}
if ($earlyfixup) {
  aline("Copied$unroll:");
}

aline("iaddl \$$u4, %ebx", "src+=$unroll");
aline("iaddl \$$u4, %ecx", "dst+=$unroll");
if ($earlyfixup) {
  aline("iaddl \$-$unroll, %edx", "cnt-=$unroll");
  aline("jg Loop", "if cnt > 0, goto Loop");
} elsif ($unroll == 1) {
  aline("iaddl \$-$unroll, %edx", "len-=$unroll");
  aline("jg Loop", "if len > 0, goto Loop");
} else {
  aline("iaddl \$-$unroll, %edx", "lmu-=$unroll");
  aline("jge Loop", "if lmu >= 0, goto Loop");
}

if (!$earlyfixup) {
  aline("SkipLoop:");


  if (!$usejump && $unroll > 1) {
    cline("Set %edx to number or remaining elements");
    $um1 = $unroll -1;
    cline("(between 0 and $um1)");
    aline("iaddl \$$unroll, %edx", "len = lmu + $unroll");
  }

  if ($usecascade == 1) {
    for ($idx = 1; $idx < $unroll; $idx = 2*$idx) {
      aline("# Handle any block of $idx elements");
      $idx4 = $idx * 4;
      aline("irmovl \$$idx,%esi", "idx = $idx");
      aline("andl %edx,%esi", "idx & len");
      aline("je Skip$idx", "If 0, goto next block");
      for ($i = 0; $i < $idx; $i++) {
	&ecpy($i);
      }
      if (2*$idx < $unroll) {
	aline("iaddl \$$idx4, %ebx", "src+=$idx");
	aline("iaddl \$$idx4, %ecx", "dst+=$idx");
      }
      bline();
      aline("Skip$idx:");
    }
  }

  if ($usejump) {
    cline("Finish remaining elements\n");
    if ($usetable) {
      cline("Find jump offset at table position (-lmu-1)");
      aline("irmovl \$-1, %esi");
      aline("subl %edx, %esi", "-1-lmu");
      aline("addl %esi, %esi", "2*(-1-lmu)");
      aline("addl %esi, %esi", "4*(-1-lmu)");
      aline("mrmovl JTab(%esi), %edx", "Fetch offset");
    } else {
      cline("Compute jump offset as 24*(-lmu-1)");
      aline("irmovl \$-1, %esi");
      aline("subl %edx, %esi", "-1-lmu");
      aline("rrmovl %esi, %edx", "-1-lmu");
      aline("addl %esi, %esi", "2*(-1-lmu)");
      aline("addl %esi, %edx", "3*(-1-lmu)");
      aline("addl %edx, %edx", "6*(-1-lmu)");
      aline("addl %edx, %edx", "12*(-1-lmu)");
      aline("addl %edx, %edx", "24*(-1-lmu)");
      aline("iaddl jstart, %edx", "jump target");
    }
    aline("pushl %edx", "Put jump target on stack");
    aline("ret", "Jump to it");
    aline("jstart:", "Copying code for remaining possible elements");
    cline("Completion code");
    $j = 0;
    for ($i = $unroll-2; $i >= 0; $i--) {
      if ($usetable) {
	aline("Copied$j:");
	$j++;
      }
      &ecpy($i);
    }
  }
  if ($usetable) {
    aline("Copied$j:");
  }

  if ($unroll > 1 && !($usecascade || $usejump)) {
    aline("# Single step remaining elements");
    aline("je Done");
    aline("SingleLoop:");
    &ecpy(0);
    aline("iaddl \$4, %ebx", "src++");
    aline("iaddl \$4, %ecx", "dst++");
    aline("iaddl \$-1, %edx", "len--");
    aline("jg SingleLoop", "if len > 0, goto SingleLoop");
  }
}

bline();
cline("#################################################################");
bline();
cline("Do not modify the following section of code");
cline("Function epilogue");
aline("Done:");
aline("popl %edi");
aline("popl %ebx");
aline("popl %esi");
aline("rrmovl %ebp, %esp");
aline("popl %ebp");
aline("ret");

if ($usetable) {
  cline("#################################################################");
  cline("# Jump table");
  aline("JTab:");
  $tsize = $unroll;
  if ($earlyfixup) {
    $tsize ++;
  }
  for ($i = 0; $i < $tsize; $i++) {
    aline(".long Copied$i");
  }
}

cline("##################################################################");
cline("# Keep the following label at the end of your function");
aline("End:");
