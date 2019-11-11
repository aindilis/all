#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Lingua::Stem qw(stem);

# system to lookup a phrase

my $phrase = shift;

my $res = lookup($phrase);
print $res;
if (! $res) {
  my @tokens = ($phrase);	# don't tokenize for now
  my $stemmmed_words_anon_array   = stem(@tokens);
  my $res = lookup($stemmmed_words_anon_array->[0]);
  print $res;
}

# examples: ill-spelt

sub lookup {
  my $phrase = shift;
  my $res = `dict "$phrase"`;
  if ($res =~ /^No definitions found for /) {
    return 0;
  } else {
    return $res;
  }
}
