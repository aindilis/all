#!/usr/bin/perl -w

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Text::Wrap qw(wrap $columns $huge);
use WordNet::QueryData;
use WordNet::SenseRelate::AllWords;

$columns = 100;
print "Creating QueryData object\n";
my $qd = WordNet::QueryData->new("/usr/share/wordnet");

# print $qd->querySense("cat#n#7", "glos");
# print $qd->querySense("can#v#1", "glos");
# print $qd->querySense("cat#n#7", "glos");
# exit(0);

my %options = (wordnet => $qd,
	       measure => 'WordNet::Similarity::lesk'
	      );

print "Creating SenseRelate object\n";
my $wsd = WordNet::SenseRelate::AllWords->new (%options);

# my @words = qw/when in the course of human events/;
# my @res = $wsd->disambiguate (window => 2,
#			      tagged => 0,
#			      scheme => 'normal',
#			      context => [@words],
#			     );
# print join (' ', @res), "\n";

print "Reading text\n";
my $f = shift;
exit unless $f;

my $text = `cat "$f"`;

print "Splitting sentences\n";
my $sentences = get_sentences($text);

print "Disambiguating sentences\n";
my $seen = {};
foreach my $sentence (@$sentences) {
  my @words;
  my @lint;
  # load a dictionary
  $sentence =~ s/\n/ /g;
  $sentence =~ s/\s+/ /g;
  $sentence =~ s/^\W*//;
  $sentence .= " ";
  my @i1 = $sentence =~ /(\w+)(\W+)/g;
  foreach my $s (@i1) {
    if ($s =~ /^\w+$/) {
      push @words, $s;
    } else {
      push @lint, $s;
    }
  }
  # now take words and wsd them
  if (@words and @words < 20) {
    my @res = $wsd->disambiguate (window => 2,
				  tagged => 0,
				  scheme => 'normal',
				  context => [@words],
				 );
    # print join (' ', @res), "\n";
    # do the seen thing
    my $i = 0;
    foreach my $wqd (@res) {
      my $word = $words[$i];
      my $lin = $lint[$i];
      if (! $seen->{$wqd}) {
	$seen->{$wqd} = 1;
	# do a lookup of its definition
	# print $qd->querySense("can#v#1", "glos");
	# print $qd->querySense("cat#n#7", "glos");
	# exit(0);
	my @text = $qd->querySense("$wqd", "glos");
	my $glos;
	if (@text) {
	  $glos = $text[0];
	}
	if ($glos) {
	  print "$word$lin\n".wrap("\t| $wqd - ", "\t| ", $glos)."\n";
	} else {
	  print "?$word?$lin";
	}
      } else {
	print "$word$lin";
      }
      ++$i;
    }
    print "\n\n";
  } else {
    print join(' ', @words), "\n\n";
  }
}

# other features to add to this are:

# quiz the user about word definitions and use textual entailment or something to get it to work

# adopt it to process every sentence but use TFIDF to identify important terms

# even recurse definitions that one has not seen before!

# allow some kind of user feedback here
