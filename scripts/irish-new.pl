#!/usr/bin/perl -w

use ALL::TTS::AbairIE;

my $text1 = `head -n 30 data/irish-sample`;
my $text2 = "Is and-sin ra imraided oc feraib hErend cia bad chóir do chomlond & do chomrac ra Coinculaind ra húair na maitni muchi arna bárach.";

my $abairie = ALL::TTS::AbairIE->new();

$abairie->Speak(Text => $text1);
