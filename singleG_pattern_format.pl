#!/usr/bin/perl -w
use strict;
#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $file = "3_way_alignment.txt";
my @species = qw/CHICK FINCH PIGEO/;



my %species;
foreach (@species) {	$species{$_} = 1; }

my %genes;
my $gname;
open FH, $file;
while (<FH>) {
	if (/>(\S+)/) {	$gname = $1; }
	elsif (/(\S+)\s+(\S+)/) {
		$gname = "uniform";
		my ($sname, $seq) = ($1, $2);

		next unless defined $species{$sname};
		my @bases = split //, $seq;
		push @{$genes{$gname}{$sname}}, @bases;
	}
}
close FH;

my %patterns;
my $pattern_counts=0;
my %gene_pattern_counts;
foreach my $gname (sort keys %genes) {
	my $total_bases = scalar @{$genes{$gname}{$species[0]}};

	my %local_patterns;
	for (my $i=0; $i < $total_bases; $i++) {
		my $good =1;

		my $pattern ='';
		foreach my $sname (@species) {
			$pattern .= uc $genes{$gname}{$sname}[$i];
		}

		$local_patterns{$pattern} ++ if $pattern =~/^[AGCT]+$/;
	}

	next unless scalar keys %local_patterns >0;
	$patterns{$gname} = \%local_patterns ;

	$pattern_counts +=scalar keys %local_patterns;
	$gene_pattern_counts{$gname} = scalar keys %local_patterns;
}
			
my $total_genes = scalar keys %patterns;

print scalar @species;
print "\t".$pattern_counts."\tP\n";
#print "G\t$total_genes";
#foreach my $gname (sort keys %patterns) {
#	print "\t".$gene_pattern_counts{$gname};
#}
print "\n\n";

my $i=-1;
foreach my $sname (@species) {
	$i++;
	print "$sname ";

	foreach my $gname (sort keys %patterns) {
		print " ";

		foreach my $pattern (sort keys %{$patterns{$gname}}) {
			my @pattern = split //, $pattern;

			print $pattern[$i];
		}
	}
	print "\n";
}

print "\n";

foreach my $gname (sort keys %patterns) {
	foreach my $pattern (sort keys %{$patterns{$gname}}) {
		my @pattern = split //, $pattern;

		print " ".$patterns{$gname}{$pattern};
	}
}
print "\n";

#-----------------------------------------------------------------------------
#---------------------------------- SUBS -------------------------------------
#-----------------------------------------------------------------------------
