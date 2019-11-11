package ALL::Metrics::TextDifficulty;

use Capability::Tokenize;

use Data::Dumper;
use IO::File;

# fix the "Texts" and also get the right capitalization rules

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Freq FreqNorm Texts / ];

sub init {
  my ($self,%args) = @_;
  $Data::Dumper::Indent = 1;
  $self->Texts({});
  $self->LoadFrequencyData();
}

sub TextDifficulty {
  my ($self,%args) = @_;
  my $freq = $self->FreqNorm;
  my $unknowns = {};
  my $unaccepted = {};
  my $j = 0;
  my $c = $args{Text};

  my $ct = tokenize_treebank($c);
  foreach my $tokenized ($ct) {

    if ($tokenized !~ /^</) {
      # Hopefully not markup

      # tokenize and iterate over each word, determining frequency
      # (if appropriate, i.e. not for numbers), and determine
      # several norms for text "difficulty" based on frequency
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

      # compute overall text scores
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
	$self->Texts->{$tokenized} =
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

sub LoadFrequencyData {
  my ($self,%args) = @_;
  my $total = 0;
  my $freq = {};
  my $freqnorm = {};
  my $file = "/var/lib/myfrdcsa/codebases/minor/language-learning/reading-difficulty-measure/anc-lexicon.tgz";
  my $c = `zcat $file`;
  foreach my $line (split /[\r\n]+/, $c) {
    if ($line =~ /^(.+) (\d+)$/) {
      $freq->{lc($1)} = $2;
      $total += $2;
    } else {
      print ".";
    }
  }
  die "Total is 0" unless $total > 0;
  print "\n";
  foreach my $key (keys %$freq) {
    $freqnorm->{$key} = $freq->{$key} / $total;
  }
  $self->Freq($freq);
  $self->FreqNorm($freqnorm);
}

sub WriteResults {
  my ($self,%args) = @_;
  if (! $args{Print}) {
    my $fh = IO::File->new;
    $fh->open(">text-info.dat");
  }
  # foreach my $key (sort {$self->Texts->{$b}->{Min} <=> $self->Texts->{$a}->{Min}} keys %{$self->Texts}) {
  foreach my $key (sort {$self->Texts->{$b}->{L1} <=> $self->Texts->{$a}->{L1}} keys %{$self->Texts}) {
    if (! $args{Print}) {
      print $fh Dumper({$key => $self->Texts->{$key}});
    } else {
      print Dumper({$key => $self->Texts->{$key}});
    }
  }
  if (! $args{Print}) {
    $fh->close();
  }
}

1;
