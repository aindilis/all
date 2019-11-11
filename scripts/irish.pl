#!/usr/bin/perl -w

use ALL::TTS::Irish;

my $text1 = `head -n 30 data/irish-sample`;
my $text2 = "Is and-sin ra imraided oc feraib hErend cia bad chóir do chomlond & do chomrac ra Coinculaind ra húair na maitni muchi arna bárach.";

ALL::TTS::Irish::SpeakText(Text => $text1);
