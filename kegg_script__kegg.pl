use Getopt::Long;
use LWP::Simple;

my $infile      = '';
my $urlPathKO   = "http://rest.kegg.jp/link/pathway/ko:";
my $urlPathEC   = "http://rest.kegg.jp/link/pathway/ec:";
my $urlEC       = "http://rest.kegg.jp/link/enzyme/ko:";
my $urlKO       = "http://rest.kegg.jp/link/ko/ec:";
my $urlPathName = "http://rest.kegg.jp/get/pathway:";

GetOptions(
	'infile|i=s'  => \$infile,
	'outfile|o=s'  => \$outfile,
	'outfilepath|p=s'  => \$outfilepath
);
$outfilepath_aux = $outfilepath."_aux";
open OUTK2E, "$infile";
open OUTFILEPATTH, ">$outfilepath_aux"; 
open OUTFILE, ">$outfile"; 

while(<OUTK2E>){
	chomp;
	my ($transcriptName,$KEGG,$KO) = split(/\t/);
	if(!($KO eq "")){
		my @kos       = split(/,/, $KO);
		$pathwayStr   = "";
		$pathwayIDStr = "";
		$ec           = $KEGG;
		foreach (@kos) {
			my $pathKOs       = get($urlPathKO.$_);
			my @pathKOs_lines = split(/\n/,$pathKOs);
			for my $i (0 .. $#pathKOs_lines){
				my ($ko,$pathway)   = split(/\t/,$pathKOs_lines[$i]);
				my ($t, $pathwayId) = split(':',$pathway);
				if (index($pathwayId, "ko") != -1) {
					if ($pathwayStr eq "") {
						$pathwayStr = $pathwayId;
					} else {
						$pathwayStr = $pathwayStr.','.$pathwayId;
					}
					my ($b, $pathwayIdOnly)     = split("ko",$pathwayId);
					if ($pathwayIDStr eq "") {
						$pathwayIDStr = $pathwayIdOnly;
					} else {
						$pathwayIDStr = $pathwayIDStr.','.$pathwayIdOnly;
					}
					my $pathwayNameT      = get($urlPathName.$pathwayId);
					my @pathwayName_lines = split(/\n/,$pathwayNameT);
					for my $j (0 .. $#pathwayName_lines) {
						if (index($pathwayName_lines[$j], "NAME") != -1) {
							my ($b, $name) = split("NAME ",$pathwayName_lines[$j]);
							$name =~ s/^\s+|\s+$//g;
							print OUTFILEPATTH $pathwayIdOnly."\t".$name."\n";
							last;
						}
					}
				}
			}
			my $ECKOs       = get($urlEC.$_);
			my @ECKOs_lines = split(/\n/,$ECKOs);
			for my $i (0 .. $#ECKOs_lines) {
				my ($ko,$ecID)  = split(/\t/,$ECKOs_lines[$i]);
				my ($t, $ec_id) = split(/\:/,$ecID);
				if ($ec eq "") {
					$ec = $ec_id;
				} else {
					$ec = $ec.",".$ec_id;
				}
			}
		}
		print OUTFILE $transcriptName."\t".$ec."\t".$KO."\t".$pathwayStr."\t".$pathwayIDStr."\n";
	}else{
		if(!($KEGG eq "")){
			my @keggs     = split(/,/, $KEGG);
			$pathwayStr   = "";
			$pathwayIDStr = "";
			$ko_str       = $KO;
			foreach (@keggs) {
				my @completeKEGG = split(/\./,$_);
				if ($#completeKEGG >= 3) {
					my $pathECs       = get($urlPathEC.$_);
					my @pathECs_lines = split(/\n/,$pathECs);
					for my $i (0 .. $#pathECs_lines){
						my ($kegg,$pathway) = split(/\t/,$pathECs_lines[$i]);
						my ($t, $pathwayId) = split(':',$pathway);
						if (index($pathwayId, "ec") != -1) {
							if ($pathwayStr eq "") {
								$pathwayStr = $pathwayId;
							} else {
								$pathwayStr = $pathwayStr.','.$pathwayId;
							}
							my ($b, $pathwayIdOnly)     = split("ec",$pathwayId);
							if ($pathwayIDStr eq "") {
								$pathwayIDStr = $pathwayIdOnly;
							} else {
								$pathwayIDStr = $pathwayIDStr.','.$pathwayIdOnly;
							}
							my $pathwayNameT      = get($urlPathName.$pathwayId);
							my @pathwayName_lines = split(/\n/,$pathwayNameT);
							for my $j (0 .. $#pathwayName_lines) {
								if (index($pathwayName_lines[$j], "NAME") != -1) {
									my ($b, $name) = split("NAME ",$pathwayName_lines[$j]);
									$name =~ s/^\s+|\s+$//g;
									print OUTFILEPATTH $pathwayIdOnly."\t".$name."\n";
									last;
								}
							}
						}
					}
					my $KOs       = get($urlKO.$_);
					my @KOs_lines = split(/\n/,$KOs);
					for my $i (0 .. $#KOs_lines) {
						my ($ec,$koID)  = split(/\t/,$KOs_lines[$i]);
						my ($t, $ko_id) = split(/\:/,$koID);
						if ($ko_str eq "") {
							$ko_str = $ko_id;
						} else {
							$ko_str = $ko_str.",".$ko_id;
						}
					}
				}
			}
			print OUTFILE $transcriptName."\t".$KEGG."\t".$ko_str."\t".$pathwayStr."\t".$pathwayIDStr."\n";
		}
	}
}

close(OUTK2E);
close(OUTFILEPATTH);
close(OUTFILE);

$res = `cat $outfilepath_aux | sort | uniq > $outfilepath`;
$res = `rm $outfilepath_aux`;
