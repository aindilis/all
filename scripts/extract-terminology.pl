#!/usr/bin/perl -w

# given a  corpus of specialized  terminology, and a larger  corpus of
# normal  words,  extract  the  most  likely terminology  for  use  in
# creating ontologies and definitions of those terms.

# use Lingua::EN::Extract::Dates;

use System::ExtractAbbrev;

use Data::Dumper;

use Lingua::EN::Tagger;
use System::MontyLingua;

my $text = `cat $ARGV[0]`;

# my $de = Lingua::EN::Extract::Dates->new;
# my $a = System::ExtractAbbrev->new();
# print Dumper($a->ExtractAbbrev(Text => $text));
# print Dumper($de->GetDates(Text => $text));

my $tagger = Lingua::EN::Tagger->new
  (stem => 0);
# print Dumper($tagger->get_words($tagger->add_tags($text)));
print Dumper($tagger->get_max_noun_phrases($tagger->add_tags($text)));

my $monty = System::MontyLingua->new;
$monty->StartServer;
print Dumper($monty->ApplyMontyLinguaToText(Text => $text));

# construct the largest possible database of definitions possible, urls acceptable as definitions

# ID, Source, Phrase, Location, Definition

# user
