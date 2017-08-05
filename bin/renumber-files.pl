#!/usr/bin/perl

use Data::Dumper;

my @files = @ARGV;

#      P1016712.JPG
my $N = 1000000;

foreach my $file (@files) {
  print "mv $file P$N.jpg\n";
  system("mv $file P$N.jpg");
  $N++;
}
