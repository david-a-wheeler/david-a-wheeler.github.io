#!/usr/bin/perl -w
use strict;

# Slurp in entire STDIN, remove junk HTML, spit it out.

undef $/;
my $buf = <STDIN>;

$buf =~ s/<span style="font-style: normal">([^<]*)<\/span>/$1/gs;
$buf =~ s/<font face="Times New Roman, serif">([^<]*)<\/font>/$1/gs;
$buf =~ s/<font face="Times New Roman, serif"><i>([^<]*)<\/i><\/font>/<i>$1<\/i>/gs;
$buf =~ s/<span style="font-weight: normal">([^<]*)<\/span>/$1/gs;
$buf =~ s/<span lang="en-US">([^<]*)<\/span>/$1/gs;
$buf =~ s/<span lang="en-US"><i>([^<]*)<\/i><\/span>/<i>$1<\/i>/gs;

$buf =~ s/<img ([^>]*)[ \n]+name=\n?"[^"<>]*"[ \n]+([^>]*)>/<img $1 $2>/gs;

print $buf;
print "\n";


