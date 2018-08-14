#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use LWP::Simple;

my $infile      = '';
my $basename 	= '';
my $urlPathKO   = "http://rest.kegg.jp/link/pathway/ko:";
my $urlPathName = "http://rest.kegg.jp/get/pathway:";

GetOptions(
        'infile|i=s'  => \$infile,
        'basename|b=s'  => \$basename
);

my $outfile = $basename."_result.txt";
my $outfile_pathways = $basename."_pathways.txt";
open INFILE, "$infile";
open OUTFILE, ">$outfile";

my %all_pathways;

while(<INFILE>){
	chomp;
	my @pathways;
	my ($gene_id, $KO_id) = split(/\t/);
	if($KO_id ne ''){
		my $pathwayResponse = get($urlPathKO.$KO_id);
		my @pathway_lines = split(/\n/,$pathwayResponse);
		for my $i (0 .. $#pathway_lines){
			my ($ko, $pathway)   = split(/\t/, $pathway_lines[$i]);
			my (undef, $pathwayId) = split(':', $pathway);
			if (index($pathwayId, "map") != -1) {
				my (undef, $pathwayIdOnly)     = split("map",$pathwayId);
				push @pathways, $pathwayIdOnly;
				$all_pathways{$pathwayIdOnly} = '';
			}
		}
		print OUTFILE $gene_id."\t".join(',', @pathways)."\n";
	}
}

close(INFILE);
close(OUTFILE);
open OUTFILEPATHWAY, ">$outfile_pathways";

foreach my $keys (keys %all_pathways) {
	my $pathwayInfoResponse = get($urlPathName.'map'.$keys);
	my @pathwayName_lines = split(/\n/,$pathwayInfoResponse);
	for my $j (0 .. $#pathwayName_lines) {
		if (index($pathwayName_lines[$j], "NAME") != -1) {
			my (undef, $name) = split("NAME ",$pathwayName_lines[$j]);
			$name =~ s/^\s+|\s+$//g;
			print OUTFILEPATHWAY $keys."\t".$name."\n";
			last;
		}
	}
}

close(OUTFILEPATHWAY);
