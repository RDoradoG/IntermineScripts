#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use LWP::Simple;

use POSIX qw(strftime);

my $oboFile        = '';
my $organellesFile = '';
my $taxonid        = '';
my $outFile        = '';
my $aspect        = '';

GetOptions(
        'obofile|o=s'  => \$oboFile,
        'organellesFile|r=s'  => \$organellesFile,
        'taxon|t=s'  => \$taxonid,
        'aspect|a=s'  => \$aspect,
        'outfile|x=s'  => \$outFile
);

if(! -f $oboFile) {
	print STDERR "please, set a valid .obo file.";
	exit;
}

if(! -f $aspect) {
	print STDERR "please, set a valid aspects file.";
	exit;
}

if(! -f $organellesFile) {
	print STDERR "please, set a valid file of organelles.";
	exit;
}

if($taxonid eq '') {
	print STDERR "please, set a taxon id.";
	exit;
}

if($outFile eq '') {
	print STDERR "please, set a outfile name.";
	exit;
}

if(-f $outFile) {
	print STDERR "The file will be overwritten.";
}

my $datestring = strftime "%Y%m%d", gmtime;

open ASPECTS, "$aspect";
my %Aspects;
while(<ASPECTS>){
	chomp;
	my ($description, $aspect) = split(/\t/);
	$Aspects{$description} = $aspect;
}

close(ASPECTS);

open OBO, "$oboFile";
my %obo;
my %obo_def;
my @goids;
my $namespace = '';
my $def = '';
my $stop_reading = 0;
while(<OBO>){
	chomp;
	if ($stop_reading == 0) {
		if (index($_, '[Term]') == 0) {
			if ($namespace ne '') {
				my $aspect = $Aspects{$namespace};
				while(my $goid = shift(@goids)) {
				    	$obo{$goid} = $aspect;
				    	$obo_def{$goid} = $def;
				}
			}
			@goids = (); 
			$namespace = '';
			$def = '';
		}

		if (index($_, '[Typedef]') == 0) {
			if ($namespace ne '') {
				my $aspect = $Aspects{$namespace};
				while(my $goid = shift(@goids)) {
				      $obo{$goid} = $aspect;
				      $obo_def{$goid} = $def;
				}
			}
			@goids = (); 
			$namespace = '';
			$def = '';
			$stop_reading = 1;
		}

		if (index($_, 'namespace:') == 0) {
			(undef, $namespace) = split(' ');
		}

		if (index($_, 'def:') == 0) {
			(undef, $def) = split(/def: /);
		}

		if (index($_, 'id:') == 0) {
			my (undef, $goid) = split(' ');
			push(@goids, $goid);
		}

		if (index($_, 'alt_id:') == 0) {
			my (undef, $goid) = split(' ');
			push(@goids, $goid);
		}
	}
}

close(OBO);

open ORGANELLES, "$organellesFile";
open OUTFILE, ">$outFile";

while(<ORGANELLES>){
	chomp;
	my ($gene_id, $all_go_str) = split(/\t/);
	my @all_go = split(/,/, $all_go_str);
	for my $i (0 .. $#all_go) {
		my $ex_go = $all_go[$i];
		my $aspect = $obo{$ex_go};
		my $defline = $obo_def{$ex_go};
		my $result_line = "phycomine\t".$gene_id."\t".$gene_id."\t\t".$all_go[$i]."\t\tIC\t\t".$aspect."\t".$defline."\t".$gene_id."\tgene\ttaxon:".$taxonid."\t".$datestring."\tphycomine\n";
		print OUTFILE $result_line;		
	}
}

close(ORGANELLES);
close(OUTFILE);
