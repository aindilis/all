#!/usr/bin/perl -w

# in the end just get TextMine packaged and installed, but in leiu of that, use Lingua::EN::Tagger;

use Data::Dumper;
use Lingua::EN::Tagger;

sub ProcessCorpus {
  my $t = Lingua::EN::Tagger->new(stem => 0);

  my $corpusdir = "corpus";

  foreach my $file (split /\n/, `ls $corpusdir`) {
    my $dir = "$corpusdir/$file";
    if (-d $dir and ! -e $dir.".results") {
      print "Loading files ($dir)\n";
      my $content;
      my $types = {};
      foreach my $line (split /\n/, `file $dir/*`) {
	if ($line =~ /^(.*?): (.*)$/) {
	  $types->{$1} = $2;
	}
      }
      foreach my $file (split /\n/, `find $dir`) {
	$filetype = $types->{$file};
	if ($filetype =~ /ASCII/) {
	  print ".";
	  my $c = `cat $file`;
	  # my $c = "";
	  $c =~ s/^\>+//smg;
	  $content .= $c;
	}
      }
      print "\n";
      print "Tagging text\n";
      my $r = {$t->get_max_noun_phrases
	       ($t->add_tags($content))};
      print "Sorting keys\n";

      my $OUT;
      open(OUT, ">$corpusdir/$file.results") or die "can't open output\n";
      foreach my $k (sort {$r->{$b} <=> $r->{$a}} keys %$r) {
	print OUT $r->{$k}."\t".$k."\n";
      }
      close(OUT);
    }
  }
}

sub UniqItems {
  my $search = shift @ARGV;
  my $results = {};
  my $corpusdir = "corpus";
  my $res = `grep -E "$search" $corpusdir/*.results`;
  foreach my $l (split /\n/, $res) {
    if ($l =~ /^(.*?):(\d+)\s+(.*)$/) {
      $results->{$3} += $2;
    }
  }

  foreach my $result (sort {$results->{$b} <=> $results->{$a}} keys %$results) {
    print $results->{$result}."\t$result\n";
  }
}
