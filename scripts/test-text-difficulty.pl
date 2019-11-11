#!/usr/bin/perl -w

use ALL::Metrics::TextDifficulty;

use Data::Dumper;
use Lingua::EN::Splitter qw(paragraphs);

my $td = ALL::Metrics::TextDifficulty->new;

my $file = "/var/lib/myfrdcsa/codebases/internal/digilib/data/google-books/books/Leabar_Aitriseoireacta_Na_nGaedeal.txt";
my $c = `head -n 3000 $file`;

my $res = paragraphs($c);
foreach my $paragraph (@$res) {
  if (length($paragraph) > 100) {
    # print Dumper($paragraph);
    print ".\n";
    $td->TextDifficulty
      (Text => $paragraph)
  }
}

$td->WriteResults;
