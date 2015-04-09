#!/usr/bin/perl
#
#
#

open FILE, "<$ARGV[0]";

$len = 0;

while($line = <FILE>) {
  next if ($line =~ /^Time taken/);
  next if ($line =~ /rows selected/);
  next if ($line =~ /^Elapsed/);
  next if ($line =~ /^\[Hive/);
  next if ($line =~ /^SLF4J/);
  next if ($line =~ /^cli/);
  $_ = $line;
  s/^(\s+)//;
  $line = $_;
  next if ($line eq "");
  @fields = split /\s+/, $line;
  if($#fields > $len) {$len = $#fields;}
  foreach $field(@fields) {
    if($field =~ /^\.(\d+)/){
        $field = "0".$field;
    }
    
    if($field =~ /^-?(\d+)\.(\d+)/) {
      if($2 == 0) {printf "%d ", $field;}
      else {printf "%.2f ", $field;}
    }
    else { print "$field "; }
  }
  print "\n";
  
}

close FILE;
