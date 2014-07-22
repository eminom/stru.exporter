#! /usr/bin/perl -w
use strict;
use warnings;

if($#ARGV != 0){
	printf("error using arguments\n");
	exit;
}

my $cmd = "cat $ARGV[0] | ./parser";
system($cmd);
die "parsing error" if $?;
