#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use LWP::Simple;

my $pathwayfile = '';
my $genefile = '';
my $outfile = '';

GetOptions(
        'pathwayfile|p=s'  => \$pathwayfile,
        'genefile|g=s'  => \$genefile,
        'outfile|o=s'  => \$outfile
);

if(! f $pathwayfile) {
	print STDERR "please, set a valid file of pathways.";
	exit;
}

if(! f $genefile) {
	print STDERR "please, set a valid file of genes.";
	exit;
}

if($outfile eq '') {
	print STDERR "please, set a out file for the results.";
	exit;
}

if(f $outfile) {
	print STDERR "The file will be overwritten.";
}

open PATHWAY, "$pathwayfile";

my %pathways_id;
my %pathways_name;
while(<PATHWAY>){
	chomp;
	my ($pathway_id, $pathway_name) = split(/\t/);
	@pathways_id{$pathway_id} = ();
	$pathways_name{$pathway_id} = $pathway_name;
}

close(PATHWAY);

open GENEFILE, "$genefile";

while(<GENEFILE>){
	chomp;
	my ($gene_id, $path_ids) = split(/\t/);
	my @paths_id = split(/,/, $path_ids);
	for my $i (0 .. $#paths_id){
		my $this_id = $paths_id[$i];
		push(@{$pathways_id{$this_id}}, $gene_id);
	}
}

close(GENEFILE);

open OUTFILE, ">$outfile";

foreach my $id(keys %pathways_id) {
	print OUTFILE 'map'.$id."\t".$pathways_name{$id}."\t".join("\t", @{$pathways_id{$id}})."\n";
}

close(OUTFILE);

