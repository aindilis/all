#!/usr/bin/perl -w

# this script defines a word the first time it is used in a sentence.
use WordNet::QueryData;

my $wn = WordNet::QueryData->new("/usr/share/wordnet");
# print $wn->querySense("cat#n#7", "glos");
# exit(0);

my $text = `cat text`;

# load a dictionary

my $dict = `cat /usr/share/dict/american-english-huge`;
my %dict;
foreach my $word (split /\n/, $dict) {
  $dict{lc($word)} = 1;
}

my @i1 = $text =~ /(\w+)(\W+)/g;
my @i2 = $text =~ /(\W+)(\w+)/g;
push @i1, @i2;

my $seen = {};
foreach my $word (@i1) {
  my $w = lc($word);
  if (! exists $seen->{$w}) {
    $seen->{$w} = 1;
    # define it, makes sense to actually do WSD and 
    # for now, just show the first sense
    my $glos;
    if ($w =~ /^\w+$/) {
      $glos = $wn->querySense("$w#n#1", "glos");
      print $wn->querySense("$w#n#7", "glos");
    }
    if ($glos) {
      print "($word - $glos)";
    } else {
      print "($word)";
    }
  } else {
    print "$word";
  }
}
