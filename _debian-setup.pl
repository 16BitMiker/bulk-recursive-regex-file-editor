#!/usr/bin/env perl

use Term::ANSIColor qw|:constants|;
use feature qw|say|;

while (<DATA>)
{
	chomp;
	next if m~^$|^\#~;
	say q|> |, YELLOW $_, RESET;
	system $_;
}

__END__
sudo apt update
sudo apt install build-essential -y
sudo apt install cpanminus -y
sudo cpanm JSON::MaybeXS
sudo cpanm Data::Dump