#!/usr/bin/perl -w

use Capability::Tokenize;

use Data::Dumper;
use IO::File;

$Data::Dumper::Indent = 1;

my $freq = {};
LoadFrequencyData();

my $sentences = {};
my $unknowns = {};
my $unaccepted = {};
my $j = 0;
foreach my $file (split /\n/, `find /var/lib/myfrdcsa/codebases/internal/all/data/languages/german/de-en/de/`) {
  ++$j;
  # last if $j > 5;
  if (-f $file) {
    print "$file\n";
    my $c = `cat "$file"`;
    my $ct = tokenize_treebank($c);
    foreach my $tokenized (split /\n/, $ct) {
      if ($tokenized !~ /^</) {
	# Hopefully not markup

	# tokenize and iterate over each word, determining frequency
	# (if appropriate, i.e. not for numbers), and determine
	# several norms for sentence "difficulty" based on frequency
	my @freqs;
	chomp $tokenized;
	# print "\t$tokenized\n";
	my @myunknowns = ();
	my @myunaccepted = ();
	foreach my $token (split /\s+/, $tokenized) {
	  if ($token =~ /^[a-zA-Zäöüß]+$/) {
	    # check whether it is in dictionary
	    if (exists $freq->{lc($token)}) {
	      push @freqs, $freq->{lc($token)};
	    } else {
	      # this is a valid word without a frequency
	      $unknowns->{$token}++;
	      push @myunknowns, $token;
	      push @freqs, 0;
	    }
	  } else {
	    if ($token =~ /^[0-9]+$/) {

	    } else {
	      $unaccepted->{$token}++;
	      push @myunaccepted, $token;
	    }
	  }
	}

	# compute overall sentence scores
	my $min = 1000;
	my $l1c = 0;
	my $l2c = 0;
	if (scalar @freqs) {
	  foreach my $freq (@freqs) {
	    if ($freq < $min) {
	      $min = $freq;
	    }
	    $l1c += $freq;
	    $l2c += $freq * $freq;
	  }
	  my $l1 = $l2c / (scalar @freqs);
	  my $l2 = sqrt($l2c);
	  # print join(", ",$min, $l1, $l2, scalar @myunknowns, scalar @myunaccepted, @myunknowns)."\n\n";
	  $sentences->{$tokenized} =
	    {
	     Min => $min,
	     L1 => $l1,
	     L2 => $l2,
	     Unknowns => \@myunknowns,
	     Unaccepted => \@myunaccepted,
	    };
	}
      }
    }
  }
}

my $fh = IO::File->new;
$fh->open(">sentence-info.dat");

foreach my $key (sort {$sentences->{$b}->{Min} <=> $sentences->{$a}->{Min}} keys %$sentences) {
  print $fh Dumper({$key => $sentences->{$key}});
}

$fh->close();

sub LoadFrequencyData {
  my $i = 1;
  foreach my $word (split /\n/, `cat /var/lib/myfrdcsa/codebases/internal/all/data/languages/german/top10000de.txt`) {
    $freq->{lc($word)} = 1/$i;
    ++$i;
  }
}
