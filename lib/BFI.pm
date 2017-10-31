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

my %symbolmap = (
  '+' => sub { $cells{$pos}++ },
	'-' => sub { $cells{$pos}-- if $cells{$pos} },
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

	  if ($skiploop){
			$skiploop = 0 if $command eq ']';
			next;
	  }

	  if ($symbolmap{$command}){
		  $symbolmap{$command}->();
	  } elsif ($command eq '[') {
			if ($cells{$pos}){
				push @markers, $commandindex;
			} else {
				$skiploop = 1;
			}
	  } elsif ($command eq ']') {
			if ($cells{$pos}) {
				# Jump back to start of loop
				$commandindex = pop @markers;
				next;
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
