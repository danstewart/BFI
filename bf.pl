#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use BFI qw/execute resetcells/;
use Term::ReadKey;
use List::Util qw/max/;

sub getkey {
	ReadMode 4;
	my $key;
	until (defined ($key = ReadKey(-1))) { }
	return $key;
}

sub getlines {
	ReadMode 0;
	my ($line, $lines, $got_code);
	# Blank lines preceding actual code input will be ignored
	# A blank line once code has started will trigger code execution
	while ($line = ReadLine(0)) {
		if ($line =~ /\S/) {
			chomp $line;
			$lines .= $line;
			$got_code = 1;
		} else {
			return $lines if ($got_code);
		}
	}
}

sub repl {
	# TODO: Add a marker for the current cell (Will be a change to displaycells)
	my $key = "";
	my $keyhistory = "";
	my %validkeys = map { $_ => 1} ('+', '-', '>', '<', '.', ',');

	do {
		execute($key) if $validkeys{$key};
		system 'clear';
		print "REPL Mode\n";
		print "=========\n\n";
		print displaycells(\%BFI::cells) . "\n\n";

		print $keyhistory .= $key if $key;

		$key = getkey();
	} while (lc $key ne 'q');
}

sub displaycells {
	my $cells = shift;

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

	foreach my $cell (sort {$a <=> $b } keys %$cells) {
		my $value = $cells->{$cell};
		my $ascii = $value < 32 ? $symbols{$value} : chr($cells->{$cell});

		my $width = max(length $value, length $cell, length $ascii);

		$indexes .= pad($cell,  " ", $width) . "|";
		$values  .= pad($value, " ", $width) . "|";
		$chars   .= pad($ascii, " ", $width) . "|";
		$breaks  .= pad("",     "-", $width) . "|";
	}

  return join "\n", ($indexes, $breaks, $values, $breaks, $chars);
}

sub pad {
	# TODO: Would be cool to centre or left align
	my ($input, $fill, $width) = @_;
	return $input . ($fill x ($width - length($input)));
}

print "Hello! Welcome to the BrainFuck Interpretor!\n";
print "To execute some code just hit E, or press ? for help.\nPress Q to quit.\n";
my $key = "";
while ($key ne 'Q' and $key ne 'q') {
	$key = getkey();

	if ($key eq 'E' or $key eq 'e') {
		print "Please enter your code: \n";
		my $line = getlines();
		my $result = execute($line);
		print "Output: " . $result . "\n" if $result;
	} elsif ($key eq 'D' or $key eq 'd') {
		print "\n" . displaycells(\%BFI::cells) . "\n";
	} elsif ($key eq 'R' or $key eq 'r') {
		resetcells();
	} elsif ($key eq '?') {
		print "Help Page\n";
		print "=========\n";
		print "E: Execute some code\n";
		print "D: Display cells\n";
		print "C: Clear the screen\n";
		print "R: Reset the cells\n";
		print "P: Enter REPL mode\n";
		print "Q: Quit\n";
		print "?: Show help\n";
	} elsif ($key eq 'C' or $key eq 'c') {
		system 'clear';
		print "Hello! Welcome to the BrainFuck Interpretor!\n";
		print "To execute some code just hit E, or press ? for help. Press Q to quit.\n";
	} elsif ($key eq "P" or $key eq "p") {
		system 'clear';
		repl();
		print "\nExited REPL - Press 'Q' again to exit\n";
	}
}

ReadMode 0;
