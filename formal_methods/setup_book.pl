#!/usr/bin/perl

# This extracts from the current input a list of html filenames if they
# are referenced using href="...", and outputs those filenames in order.
# Quick script by David A. Wheeler.

while (<>) {
  if (/href="([^"]+)"/)  {
     $filename = $1;
     if ($filename =~ /\.[Cc][Ss][Ss]/) {next;}   # Skip .css files.
     # $filename =~ s/ /\\ /;  # Protect spaces in filenames.
     # print "$1 \\\n";
     print "$1\n";
  }
}
print "\n";

