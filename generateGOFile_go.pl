#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use LWP::Simple;

use POSIX qw(strftime);

my $annotation = '';
my $defline    = '';
my $aspect     = '';
my $obo        = '';
my $result     = '';
my $taxon      = ''; #Chlamydomona Reinhardtii: 3055

GetOptions(
    'annotation|a=s' => \$annotation,
	'defline|d=s' => \$defline,
	'aspect|s=s' => \$aspect,
	'obo|o=s' => \$obo,
	'result|r=s' => \$result,
	'taxon|t=s' => \$taxon
);

if(! -f $annotation) {
	print STDERR "please, set a valid annotation file.";
	exit;
}

if(! -f $defline) {
	print STDERR "please, set a valid defline file.";
	exit;
}

if(! -f $aspect) {
	print STDERR "please, set a valid aspect file.";
	exit;
}

if(! -f $obo) {
	print STDERR "please, set a valid .obo file.";
	exit;
}

if(-f $result) {
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

open DEFLINE, "$defline";
my %Defline;
while(<DEFLINE>){
	chomp;
	my ($gen_id, undef, $def_line) = split(/\t/);
	$Defline{$gen_id} = $def_line;
}

close(DEFLINE);

open OBO, "$obo";
my %obo;
my @goids;
my $namespace = '';
my $stop_reading = 0;
while(<OBO>){
	chomp;
	if ($stop_reading == 0) {
		if (index($_, '[Term]') == 0) {
			if ($namespace ne '') {
				my $aspect = $Aspects{$namespace};
				while(my $goid = shift(@goids)) {
				      $obo{$goid} = $aspect;
				}
			}
			@goids = (); 
			$namespace = '';
		}

		if (index($_, '[Typedef]') == 0) {
			if ($namespace ne '') {
				my $aspect = $Aspects{$namespace};
				while(my $goid = shift(@goids)) {
				      $obo{$goid} = $aspect;
				}
			}
			@goids = (); 
			$namespace = '';
			$stop_reading = 1;
		}

		if (index($_, 'namespace:') == 0) {
			(undef, $namespace) = split(' ');
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

open ANNOTATION, "$annotation";
open OUTFILE, ">$result";
my $firts_line = 1;
while(<ANNOTATION>){
	chomp;
	if ($firts_line == 1) {
		$firts_line = 0
	} else {
		my $def_line = '';
		my (undef, undef, $gen_id, undef, undef, undef, undef, undef, undef, $gos, undef, undef, undef) = split(/\t/);
		my $gene_id_str = $gen_id.".v5.5";
		if (exists $Defline{$gen_id}) {
		    $def_line = $Defline{$gen_id};
		} else {
		    $def_line = '';
		}
		my @allGo = split(/,/, $gos);
		while(my $go = shift(@allGo)) {
			my $aspect = $obo{$go};
			my $new_line = "phycomine\t".$gene_id_str."\t".$gene_id_str."\t\t".$go."\t\tIC\t\t".$aspect."\t".$def_line."\t".$gene_id_str."\tgene\ttaxon:".$taxon."\t".$datestring."\tphycomine\n";
			print OUTFILE $new_line;
		}
	}
}

close(OUTFILE);
close(ANNOTATION);
