#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use LWP::Simple;

my $proteinFile = '';
my $blastable = '';
my $basename = '';

GetOptions(
        'infile|i=s'  => \$proteinFile,
        'blastable|b=s'  => \$blastable,
        'basename|o=s'  => \$basename
);

if (!-f $proteinFile) {
	print STDERR "$proteinFile does not exists.";
	exit 1
}

if (!-f $blastable) {
	print STDERR "$blastable does not exists.";
	exit 1
}

if (!$basename) {
	print STDERR "Fill --basename variable.";
	exit 1
}

my %ids;
open INFILE, "$proteinFile";
while(<INFILE>) {
	chomp;
	if (/^>/) {
		my $id = $_;
		$id =~ s/>//;
		$ids{$id} = '';
	}
}
close(INFILE);
open BLASTABLE, "$blastable";
while(<BLASTABLE>) {
	chomp;
	my ($tableAccesions, $proteinid) = split(/\t/);
	my (undef, $accession, undef) = split(/\|/, $tableAccesions);
	if(exists $ids{$proteinid}) {
		$ids{$proteinid} = $ids{$proteinid}.','.$accession;
	}
}	
close(BLASTABLE);
my $fileKO = $basename.'_KO';
my $fileGO = $basename.'_GO';
open BASENAMEKO, ">$fileKO";
open BASENAMEGO, ">$fileGO";
my $url = 'https://pir.georgetown.edu/cgi-bin/idmapping.pl';
foreach my $id(keys %ids) {
	my %kosTable;
	my %gosTable;
	my $uriKO = $url.'?from_fields=IDACC&to_fields=KO&ids='.$ids{$id};
	my $uriGO = $url.'?from_fields=IDACC&to_fields=GO&ids='.$ids{$id};
	my $respKO = get($uriKO);
	my $respGO = get($uriGO);
	my @respKO_lines = split(/\n/,$respKO);
	my $Kos = '';
	foreach my $line(@respKO_lines) {
		next if ($line =~ /^</);
		next if ($line =~ /^MSG:/);
		next if ($line =~ /^---/);
		next if ($line =~ /^UniProtKB/);
		next if ($line =~ /^$/);
		my (undef, $KOids) = split(/\s+/, $line);
		if($KOids ne '') {
			my @ko_lists = split(/,/, $KOids);
			foreach my $k(@ko_lists) {
				$kosTable{$k} = 1;
			}
		}
	}
	print BASENAMEKO $id."\t".join(',',keys(%kosTable))."\n";
	my @respGO_lines = split(/\n/,$respGO);
	my $Gos = '';
	foreach my $line(@respGO_lines) {
		next if ($line =~ /^</);
		next if ($line =~ /^MSG:/);
		next if ($line =~ /^---/);
		next if ($line =~ /^UniProtKB/);
		next if ($line =~ /^$/);
		my (undef, $GOids) = split(/\s+/, $line);
		if($GOids ne '') {
			my @go_lists = split(/,/, $GOids);
			foreach my $g(@go_lists) {
				$gosTable{$g} = 1;
			}
		}
	}
	print BASENAMEGO $id."\t".join(',',keys(%gosTable))."\n";
}
close(BASENAMEKO);
close(BASENAMEGO);
