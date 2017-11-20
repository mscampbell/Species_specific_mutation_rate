#!/usr/bin/perl -w 
use strict;
use lib ('/home/mcampbell/lib');
use PostData;
use Getopt::Std;
use vars qw($opt_i $opt_e $opt_g $opt_p $opt_c $opt_m $opt_u);
getopts('iegpcmu');
use FileHandle;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "\n\n\t sorts wublast alignment reports by query id
\n\tUSAGE: blast_sorter.pl <blast_report> > sorted_blast_report.tblastx
\n\n";

my $FILE = $ARGV[0];
die($usage) unless $ARGV[0];

my %HASH;
my $COUNT = 0;
my %SHASH;
parse($FILE);
reasign_keys();
sort_print();
#PostData(\%HASH);
#PostData(\%SHASH);
#-----------------------------------------------------------------------------
#---------------------------------- SUBS -------------------------------------
#-----------------------------------------------------------------------------
sub sort_print{
    foreach my $key (keys %SHASH){
	print @{$SHASH{$key}};
    }
}
#-----------------------------------------------------------------------------
sub reasign_keys{
    
    foreach my $key (keys %HASH){
	$SHASH{$HASH{$key}->[7]} = $HASH{$key};
    }
}
#-----------------------------------------------------------------------------
sub parse{

    my $file = shift;       
    
    my $fh = new FileHandle;
    $fh->open($file);
    
    while (defined(my $line = <$fh>)){
	if ($line =~ /^TBLASTX/){
	    $COUNT++;
	}
	    push(@{$HASH{$COUNT}},$line);
    }
    $fh->close();
}
#-----------------------------------------------------------------------------

