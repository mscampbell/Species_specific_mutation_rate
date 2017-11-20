#!/usr/bin/perl -w 
use strict;
use lib ('/home/mcampbell/lib');
use PostData;
use Getopt::Std;
use vars qw($opt_i $opt_e $opt_g $opt_p $opt_c $opt_b $opt_n);
getopts('iegpcb:n:');
use FileHandle;
use Statistics::Descriptive;
#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "\n\n\t
-b number of boot straps
-n pecent of the alignmetns ot use in each bootstrap
\n\n";

my $FILE = $ARGV[0];
my $TREE = $ARGV[1];
my %ALIGN;
my %RATES;
die($usage) unless $ARGV[1];
boot();
stats();
#PostData(\%RATES);
#-----------------------------------------------------------------------------
#---------------------------------- SUBS -------------------------------------
#-----------------------------------------------------------------------------
sub stats{
    #9spine
    print "\ncritter\tmean_mutaiton_rate\tstandard_deviation\n";
    my $stat = Statistics::Descriptive::Full->new();
    $stat->add_data($RATES{nsp});
    my $mean = $stat->mean();
    my $sd = $stat->standard_deviation();
    print "Nine_s\t$mean\t$sd\n";

    $stat = Statistics::Descriptive::Full->new();
    $stat->add_data($RATES{tsp});
    $mean = $stat->mean();
    $sd = $stat->standard_deviation();
    print "Three_s\t$mean\t$sd\n";

$stat = Statistics::Descriptive::Full->new();
    $stat->add_data($RATES{fug});
    $mean = $stat->mean();
    $sd = $stat->standard_deviation();
    print "Fugu\t$mean\t$sd\n";
    
#my $med_nsp = median($RATES{nsp});
    #print "\n\nnsp:$med_nsp\n\n"
}
#-----------------------------------------------------------------------------
sub boot{
    my $counter=1;
    while ($counter <= $opt_b){
	parse($FILE);
	sample();
	run_paml();
	system("rm -f 3_way_alignment_$opt_n"); # unless $counter == $opt_b;
	$counter++;

    }
}
#-----------------------------------------------------------------------------
sub run_paml{
    my $bit = 0;
    my $rate_line = 0;
    system("\.\/9s_singleG_pattern_format.pl 3_way_alignment_$opt_n >pattern\.txt");
    system("baseml");

    my $fh = new FileHandle;
    $fh->open("res\.out");
    
    while (defined(my $line = <$fh>)){
	chomp $line;
	if ($rate_line == 1){
	    
	    my @array = split(/\s+/, $line);
	    #print join("\n", @array);
	    push(@{$RATES{'tsp'}}, $array[1]);
	    push(@{$RATES{'nsp'}}, $array[4]);
	    push(@{$RATES{'fug'}}, $array[7]);
	    print $line;
	    $rate_line =0;
	}
	elsif ($line eq 'Rates for branch groups'){
	    #print $line."\n";
	    $bit = 1
	}
        if ($bit == 1){
	    #print $line."\n";
	    $bit =0;
	    $rate_line =1;
	}
    }
    $fh->close();
    
}
#-----------------------------------------------------------------------------
sub sample{
#sub samples the alignment file and prints a file for paml input
    my $fho = new FileHandle;
    $fho->open(">3_way_alignment_$opt_n");
    
    foreach my $key (keys %ALIGN){
	my $frac = rand(1);
	if ($frac <= $opt_n/100){
	    print $fho "$key";
	    print $fho @{$ALIGN{$key}};
	}
    }
    $fho->close();
}
#-----------------------------------------------------------------------------
sub parse{

    my $file = shift;       
    my $cur_key = 0;
    my $fh = new FileHandle;
    $fh->open($file);
    
    while (defined(my $line = <$fh>)){

	if ($line =~ /^>/){
	    $cur_key = $line;
	}
	else { push(@{$ALIGN{$cur_key}}, $line);}
    }
    $fh->close();
    
}
#-----------------------------------------------------------------------------
sub median{
    my $array = shift;
    @{$array} = sort {$a <=> $b} @{$array};
    my $count = scalar (@{$array});
    if ($count % 2) {
        return $array->[int($count/2)];
    } 
    else {
        return ($array->[$count/2] + $array->[$count/2 - 1]) / 2;
    }
}

