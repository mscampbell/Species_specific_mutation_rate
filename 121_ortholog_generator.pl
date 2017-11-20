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
my $usage = "\n\n\t
takes recipricol best hit blast searches and outputs one to one orthologs

121_ortholog_generator.pl a2b.blast b2a.blast
\n\n";

my $FILE1 = $ARGV[0];
my $FILE2 = $ARGV[1];
die($usage) unless $ARGV[0];
my %DATA;


parse($FILE1, 'a');
parse($FILE2, 'b');
do_stuff();
#PostData(\%DATA);
#-----------------------------------------------------------------------------
#---------------------------------- SUBS -------------------------------------
#-----------------------------------------------------------------------------
sub check_the_other_one{
    my $x = shift;
    
    foreach my $y (keys%{$DATA{'b'}}){
	if (@{$DATA{'b'}{$y}} ==1 && @{$DATA{'b'}{$y}}[0] eq $x){
	    print "$x\t$y\n";
	}
    }
}
#-----------------------------------------------------------------------------
sub do_stuff{
    foreach my $x (keys %{$DATA{'a'}}){
	#print $x."\t" . @{$DATA{'a'}{$x}} ."\n";
	if (@{$DATA{'a'}{$x}} == 1){
	    #print "121 $x \n";
	    check_the_other_one($x);
	}
    }
}
#-----------------------------------------------------------------------------
sub parse{

    my $file = shift;       
    my $flag = shift;

    my $fh = new FileHandle;
    $fh->open($file);
    
    while (defined(my $line = <$fh>)){
	chomp($line);
	my @array = split(/\t/, $line);
	#$DATA{$flag}{'count'}{$array[1]}++;
	push(@{$DATA{$flag}{$array[1]}}, $array[0]);
    }
    $fh->close();
}
#-----------------------------------------------------------------------------

