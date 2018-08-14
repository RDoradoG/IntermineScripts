#!/usr/bin/perl

use strict;
use warnings;

my %genes;
open IN, $ARGV[0];
while(<IN>){
 chomp;
 my @f=split(/\t/);
 if(exists($genes{$f[0]})){
  warn "Already seen $f[0]\n";
 }
 my @k=split(/,/,$f[1]);
 if(@k>1){
  foreach my $ko(@k){
   print "$f[0]\t$ko\n";
  }
 }
 else{
  print "$_\n";
 }
}
