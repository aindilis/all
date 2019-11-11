#!/usr/bin/perl -w

use Data::Dumper;
use Lingua::EN::Tagger;
use PerlLib::HTMLConverter;

# this is the program that helps the user to view text

# should be |web browser] mode} and also <mode> that works in <Emacs>,
# although could just use <w3m> to get it to work in <Emacs>

# token should
# tags
# token be
# tags 1 2
# token web
# tags
# token browser
# tags 1
# token mode
# tags 2

my $tagger = Lingua::EN::Tagger->new(stem => 0);
my $converter = PerlLib::HTMLConverter->new;
my $phrasedict = {};

sub filter {
  my %args = @_;
  my $text = $args{Text};
  my $txt = $converter->ConvertToTxt(Contents => $text);
  my %res = $tagger->get_max_noun_phrases($tagger->add_tags($txt));
  foreach my $key (keys %res) {
    $phrasedict->{$key}++;
  }
  my @triplets = $text =~ /(\W*)(\w+)(\W*)/g;
  while (@triplets) {
    push @res, [splice @triplets, 0,3];
  }
  print Dumper(\@res);
}


