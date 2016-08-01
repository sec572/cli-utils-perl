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
# Name:		min.pl
# Description:	A simple script to provide the smallest number within the text
#		read in via STDIN or an input file which matches a number.
# Author:	Eddie N. (en@sector572.com)
#
################################################################################

use strict;
use Getopt::Std;

sub usage($);

our($opt_i, $opt_h, $opt_v);
getopts('i:hv');

if(($opt_h && ($opt_i || $opt_v)) || ($#ARGV > -1 && !$opt_i))
{
	usage(1);
}
elsif($opt_h && !$opt_i && !$opt_v)
{
	usage(0);
}

my $fileName = $opt_i;
my $verbose = $opt_v;
my $fileHandle;

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

if($fileHandle && tell($fileHandle) != -1)
{
	my $number = undef;

	while(<$fileHandle>)
	{
		chomp;

		if($_ =~ m/^(-)?[\d]*(\.[\d]+)?$/)
		{
			if($_ < $number || $number == undef)
			{
				$number = $_;
			}
		}
		else
		{
			if($verbose)
			{
				print STDERR "Ignoring: $_\n";
			}
		}
	}

	print "$number\n";

	close($fileHandle);
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
endl

	exit($exitStatus);
}
