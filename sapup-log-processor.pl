#!/usr/bin/perl
#use warnings

#if we need to get screen feedback to get a little clue on debugging, set the variable to 1, else keep it on 0
$DEBUG=0;

#check if we are passing 2 arguments, if not give error and show the correct syntax
if($#ARGV<1){
    print "This script takes a file with a phase name per line, and a SAPup.log file and outputs a out.csv file with the phase and ending timestamp";
	print "Syntax: sapup-log-processor.pl <file_with_phases> <sapup.log>\n";
    exit 1;
}

if($DEBUG){ #print both parameters
	print "Parametre 1: $ARGV[0]\n";
	print "Parametre 2: $ARGV[1]\n";
}


#open files and save to local arrays
open FILE, $ARGV[0] or die $!;
@phases = <FILE>;
close FILE;
$phaselines=@phases;
if($DEBUG){
	print("phases read $phaselines lines\n");
	#print @phases;
}

open FILE, $ARGV[1] or die $!;
@sapuplog = <FILE>;
close FILE;
$sapuploglines=@sapuplog;
if($DEBUG){
	print("sapuplog read $sapuploglines lines\n");
	#print @sapuplog;
}

#open output file
open OUTPUT, '>out.csv' or die $!;

#main loop, for each phase find the "finished at" line and search for
#"SUCCEEDED", then get the timestamp for that line, format it into a 
#easily readable format and write it to file out.csv
for($p=0;$p<$phaselines;$p++){
	$phase=@phases[$p];
	chomp($phase);
	if($DEBUG){
		print("$phase\n");
	}	
	for($i=0;$i<$sapuploglines;$i++){
		if(index(@sapuplog[$i],$phase)!=-1){
			$notfound=1;
			while($notfound){
				$i++;
				if(index(@sapuplog[$i],"finished at")!=-1){
					if(index(@sapuplog[$i],"SUCCEEDED")!=-1){
						$notfound = 0;
						my ($timestamp) = @sapuplog[$i] =~ /(\d{14})/;
						my ($year, $month, $day, $h, $m, $s) = unpack("A4 A2 A2 A2 A2 A2", $timestamp);
						$str=$phase.",".$h.":".$m.":".$s;
						print OUTPUT "$str\n";
						if($DEBUG){
							print($i." ".@sapuplog[$i]."\n");
							print($timestamp."\n");
							printf("$day-$month-$year $h:$m:$s\n");
						}
					}
				}
			}
			if(!$notfound){#when found the finished succeded of the phase, force the "for" loop ending condition to go to next phase
				$i=$sapuploglines
			}
			
			if($DEBUG){
				printf($i." ".$phase."\n");
			}
		}
	}	
}