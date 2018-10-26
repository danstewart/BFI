#!/usr/bin/perl

package BFI;

use strict;
use warnings;
use 5.6.0; # for 'our'

use Exporter qw/import/;
our @EXPORT_OK = qw/execute resetcells/;

# INSTRUCTIONS
#-------------------------------
# + : increment current cell
# - : decrement current cell
# , : read STDIN into cell
# . : print cell to STDOUT
# > : shift to next cell
# < : shift to previous cell
# [ : jump to ']' if current cell is 0, else go to next command
# ] : jump back to '[' if current cell is greater than 0, else go to next command

our %cells;
$cells{$_} = 0 for (0..10);
my $pos = 0;
my $output = "";

sub in {
	print "Enter input: ";
	my $input = <STDIN>;
	chomp $input;
	$cells{$pos} = ord($input);
}

# 8-bit cell size is traditional and still the most common (says Wikipedia).
# Some BF test programs (including some in this module's tests) assume this.
# + and - operations therefore constrained to a 0 - 255 value range.
my %symbolmap = (
  '+' => sub { $cells{$pos}++;
	              $cells{$pos} = 0 if ($cells{$pos} > 255);
	            },
	'-' => sub { ($cells{$pos} == 0) ?
	              $cells{$pos} = 255 :
	              $cells{$pos}--;
	            },
	'>' => sub { $pos++; $cells{$pos} = 0 if not defined $cells{$pos} },
	'<' => sub { $pos-- if $pos },
	'.' => sub { $output .= chr $cells{$pos} },
	',' => \&in
);

sub execute {
	my $code = shift;
	my @commands = split //, $code;
	my $commandindex = 0;
	my @markers;
	my $skiploop;
	$output = "";

	while ($commandindex <= $#commands) {
		my $command = $commands[$commandindex];

	  if ($symbolmap{$command}){
		  $symbolmap{$command}->() unless ($skiploop);
	  } elsif ($command eq '[') {
			if ($skiploop) {
				# May pass through new, nested [] during skiploop
				# Need to keep track 
				$skiploop++;
			} elsif ($cells{$pos}){
				push @markers, $commandindex;
			} else {
				$skiploop = 1;
			}
	  } elsif ($command eq ']') {
			if ($skiploop) {
				$skiploop--;
			} elsif ($cells{$pos}) {
				# Jump back to start of loop
				$commandindex = pop @markers;
				next;
			} else {
				# The [] that is ending may be inside a [] that has more loops to do.
				# Important to pop the inner []'s commandindex, so control
				# returns to the outer [ when the outer ] is subsequently enountered.
				pop @markers;
			}
		}

		$commandindex++;
  }

	return $output if $output;
}

sub resetcells {
	undef %cells;
	$cells{$_} = 0 for (0..10);
}

1;
