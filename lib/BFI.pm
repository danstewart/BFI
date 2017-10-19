#!/usr/bin/perl

package BFI;

use strict;
use warnings;
use List::Util qw/max/;

use Exporter qw/import/;
our @EXPORT_OK = qw/execute displaycells resetcells/;

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

my %cells;
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

sub pad {
	# TODO: Would be cool to centre or left align
	my ($input, $fill, $width) = @_;
	return $input . ($fill x ($width - length($input)));
}

sub displaycells {
	my $indexes = "Cell  |";
	my $values  = "Value |";
	my $chars   = "ASCII |";
	my $breaks  = "------|";

	# This is used to convert chars that don't display correctly
	# Or mess up the table (like new lines)
	my %symbols = (
		0  => "NUL", 1  => "SOH", 2  => "STX", 3  => "ETX", 4 => "EOT",
		5  => "ENQ", 6  => "ACK", 7  => "BEL", 8  => "BS",  9 => "HT",
		10 => "LF",  11 => "VT",  12 => "FF",  13 => "CR",  14 => "SO",
		15 => "SI",  16 => "DLE", 17 => "DC1", 18 => "DC2", 19 => "DC3",
		20 => "DC4", 21 => "NAK", 22 => "SYN", 23 => "ETB", 24 => "CAN",
		25 => "EM",  26 => "SUB", 27 => "ESC", 28 => "FS",  29 => "GS",
		30 => "RS",  31 => "US"
	);

	foreach my $cell (sort {$a <=> $b } keys %cells) {
		my $value = $cells{$cell};
		my $ascii = $value < 32 ? $symbols{$value} : chr($cells{$cell});

		my $width = max(length $value, length $cell, length $ascii);

		$indexes .= pad($cell,  " ", $width) . "|";
		$values  .= pad($value, " ", $width) . "|";
		$chars   .= pad($ascii, " ", $width) . "|";
		$breaks  .= pad("",     "-", $width) . "|";
	}

  return join "\n", ($indexes, $breaks, $values, $breaks, $chars);
}

1;
