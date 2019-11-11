#!/usr/bin/perl -w

use Data::Dumper;
use Lingua::Identify qw(:language_identification);

GetLanguage
  (Text =>  "Hello there.  My name is Roger Crankshaw.  I hope to be of some assistance.");

GetLanguage
  (Text => "Is and-sin ra imraided oc feraib
hErend cia bad chóir do chomlond & do
chomrac ra Coinculaind ra húair na
maitni muchi arna bárach. Issed ra
raidsetar uile co m-bad é Fer diad mac
Damain meic Dáre, in mílid mórchalma
d'feraib Domnand. Daig bha cosmail &  ");

sub GetLanguage {
  my %args = @_;
  my %res = langof($args{Text});
  foreach my $key (sort {$res{$b} <=> $res{$a}} keys %res) {
    print $key."\t".$res{$key}."\n";
  }
  print "\n\n";
}
