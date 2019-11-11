#!/usr/bin/perl -w

use System::Apertium;

use Data::Dumper;

my $apertium = System::Apertium->new
  (ReadableLanguages => ["ca"]);

my $contents = `cat text2`;

print Dumper
  ($apertium->Translate
   (Text => $contents));
