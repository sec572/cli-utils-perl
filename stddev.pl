#!/usr/bin/perl

#   Copyright 2016 Eddie N. <en@sector572.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

################################################################################
#
# Name:		stddev.pl
# Description:	A simple script to provide the standard deviation of text read
#		in via STDIN or an input file which matches a number.
# Author:	Eddie N. (en@sector572.com)
#
################################################################################

use strict;
use Getopt::Std;

sub usage($);

our($opt_i, $opt_h, $opt_v, $opt_m, $opt_M, $opt_p, $opt_s);
getopts('i:hvmMps');

if(($opt_h && ($opt_i || $opt_m || $opt_M || $opt_p || $opt_v || $opt_s)) ||
	($#ARGV > -1 && !$opt_i))
{
	usage(1);
}
elsif($opt_m && $opt_M)
{
	usage(1);
}
elsif($opt_h && !$opt_i && !$opt_v && !$opt_m && !$opt_M && !$opt_p && !$opt_s)
{
	usage(0);
}

my $fileName = $opt_i;
my $verbose = $opt_v;
my $fileHandle;
my $numberCount = 0;
my @numbers = ();
my $average = 0;
my $minimum = $opt_m;
my $maximum = $opt_M;
my $population = $opt_p;
my $summarize = $opt_s;

if(length($fileName) > 0)
{
	if(!open($fileHandle, "< $fileName"))
	{
		print STDERR "Unable to open file $fileName.\n";
		exit(1);
	}
}
else
{
	$fileHandle = *STDIN;
}

# Calculate the mean.
if($fileHandle && tell($fileHandle) != -1)
{
	my $total = 0;

	while(<$fileHandle>)
	{
		chomp;

		if($_ =~ m/^(-)?[\d]*(\.[\d]+)?$/)
		{
			$numberCount++;
			push(@numbers, $_);
			$total += $_;
		}
		else
		{
			if($verbose)
			{
				print STDERR "Ignoring: $_\n";
			}
		}
	}

	close($fileHandle);

	if($numberCount > 0 && $total > 0)
	{
		$average = $total / $numberCount;

		# Find the variance
		my $vTotal = 0;
		my $vNumbers = 0;
		foreach my $number (@numbers)
		{
			my $delta = $number - $average;
			$vTotal += $delta ** 2;
			$vNumbers++;
		}

		my $stddev = 0;
		my $variance = 0;
		my $minStddev = 0;
		my $maxStddev = 0;

		if($population)
		{
			$variance = $vTotal / $vNumbers;
		}
		else
		{
			$variance = $vTotal / ($vNumbers - 1);
		}

		$stddev = sqrt($variance);
		$minStddev = $average - $stddev;
		$maxStddev = $average + $stddev;

		if($minimum)
		{
			$stddev = $minStddev;
		}
		elsif($maximum)
		{
			$stddev = $maxStddev;
		}

		if($summarize)
		{
			printf("%-10s\t%-10s\t%-10s\t%-10s\t%-10s\n",
				"mean",
				"variance",
				"stddev",
				"min (stddev)",
				"max (stddev)");
			printf("%-10.3lf\t%-10.3lf\t%-10.3lf\t%-10.3lf\t%-10.3lf\n",
				$average,
				$variance,
				$stddev,
				$minStddev,
				$maxStddev);
		}
		else
		{
			print "$stddev\n";
		}
	}
}

# Subroutines

sub usage($)
{
	my $exitStatus = shift;

	print STDERR <<endl;
Usage:
	cat <file> | $0
	$0 -i <file>

Options:
	-i Input file
	-v Verbose
	-p Population standard deviation
	-m minimum standard deviation
	-M maximum standard deviation
endl

	exit($exitStatus);
}
