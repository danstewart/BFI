#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use BFI qw/execute displaycells resetcells/;
use Term::ReadKey;

# TODO: the displaycells sub probably belongs
# here rather than in the BFI package.
# The BFI package should only contain brainfuck
# processing logic.

sub getkey {
	ReadMode 4;
	my $key;
	until (defined ($key = ReadKey(-1))) { }
	return $key;
}

sub getline {
	ReadMode 0;
	my $line;
	while (not defined ($line = ReadLine(0))) { }
	chomp $line;
	return $line;
}

sub repl {
	# TODO: Tidy to avoid having to print before loop and in loop
	# TODO: Tidy to avoid having to next if key is Q
	# TODO: Add a marker for the current cell (Will be a change to displaycells)
	my $key = "";
	my $keyhistory = "";
	my %validkeys = map { $_ => 1} ('+', '-', '>', '<', '.', ',');

	print "REPL Mode\n";
	print "=========\n\n";
	print displaycells() . "\n\n";
	do {
		execute($key) if $validkeys{$key};
		system 'clear';
		print "REPL Mode\n";	
		print "=========\n\n";
		print displaycells() . "\n\n";

		print $keyhistory .= $key if $key;

		$key = getkey();
	} while (lc $key ne 'q');
}

print "Hello! Welcome to the BrainFuck Interpretor!\n";
print "To execute some code just hit E, or press ? for help.\nPress Q to quit.\n";
my $key = "";
while ($key ne 'Q' and $key ne 'q') {
	$key = getkey();

	if ($key eq 'E' or $key eq 'e') {
		# TODO: Allow line breaks
		#       Maybe accept input after 1 or 2 blank lines
		print "Please enter your code: \n";
		my $line = getline();
		my $result = execute($line);
		print "Output: " . $result . "\n" if $result;
	} elsif ($key eq 'D' or $key eq 'd') {
		print "\n" . displaycells() . "\n";
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
