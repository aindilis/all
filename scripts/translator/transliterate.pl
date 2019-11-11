#!/usr/bin/perl -w

use BOSS::Config;

use Data::Dumper;
use Lingua::Identify qw(:language_identification);
use Net::Dict;
use Text::Wrap;

# this is a simple Irish English bi-directional translator
# it should only show the words it thinks the user doesn't know

# use the language guesser

$specification = q(
	-f <file>	File to translate
	-t <text>	Text to translate
	-db <database>	Database
  );

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/all";
my $dir = "$UNIVERSAL::systemdir/scripts/translator";

my $text;
if (exists $conf->{'-t'}) {
  $text = $conf->{'-t'};
} elsif (exists $conf->{'-f'}) {
  $file = $conf->{'-f'};
  $text = `cat "$file"`;
}

my $c = $text;
my $lang = uc(scalar langof($c));
print "LANG: $lang\n";

$dict = Net::Dict->new('localhost');

# begin the translation
foreach my $token (split /\s+/,$c) {
  if (! exists $seen->{$token}) {
    my $lookup = Lookup
      (
       Token => $token,
       Database => $conf->{'-db'},
      );
    if (scalar @$lookup) {
      print $token."\n";
      my @list;
      foreach my $text (@$lookup) {
	push @list, join ("\n", map {"\t$_"} split /\n/, $text);
      }
      print join("\n\t--------------\n", @list)."\n";
    } else {
      print "$token\n";
    }
    $seen->{$token} = 1;
  } else {
    print "$token\t...\n";
  }
}

sub Lookup {
  my %args = @_;
  my $token = $args{Token};
  my $result;
  $h = $dict->define($token, $args{Database});

  my @results;
  foreach my $list (@$h) {
    push @results, $list->[1];
  }
  return \@results;
  # return join(" ||| ", map {join("  ", (split /\n/, $_))} @results);
}
