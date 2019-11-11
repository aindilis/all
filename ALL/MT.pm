package ALL::MT;

use Data::Dumper;
use Lingua::Identify qw(:language_identification);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MTs Engines /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MTs({});
  $self->Engines
    ({
      "Apertium" => {
		     Preference => 0.5,
		     Pairs => {
			       "en" => {
					"es" => 1,
				       },
			      },
		    },
      "BabelFish" => {
		      Preference => 1,
		      Sources => {
				  "us" => 1,
				  "en" => 1,
				  "es" => 1,
				  "de" => 1,
				 },
		      Destinations => {
				       "us" => 1,
				       "en" => 1,
				       "es" => 1,
				       "de" => 1,
				      },
		     },
     });
}

sub Translate {
  my ($self,%args) = @_;
  #   return $self->MyMT->Translate
  #     (
  #      Text => $args{Text},
  #      SourceLanguage => $args{SourceLanguage},
  #      DestinationLanguage => $args{DestinationLanguage},
  #     );

  # we just want to see which ones are provided by which machine
  # translation systems

  # have an option for doing it locally without going to an external
  # service (you know, use Apertium, etc)

  if (defined $args{SourceLanguage}) {
    my $res = $self->PrimeMT
      (
       SourceLanguage => $args{SourceLanguage},
       DestinationLanguage => $args{DestinationLanguage},
      );
    if ($res->{Success}) {
      # print "going ahead\n";
      return $self->MTs->{$res->{Result}}->Translate
	(
	 Text => $args{Text},
	 SourceLanguage => $args{SourceLanguage},
	 DestinationLanguage => $args{DestinationLanguage},
	);
    }
  } else {
    # classify the language first
    # need to break it down into multiple segments if necessary,
    # therefore annotate the text with the attributes
    my @items;
    foreach my $segment ($self->ClassifyLanguage(Text => $args{Text})) {
      print Dumper($segment);
      # manage the various MT
      my $res2 = $self->Translate
	(
	 Text => $segment->{Text},
	 SourceLanguage => $segment->{SourceLanguage},
	 DestinationLanguage => $args{DestinationLanguage},
	);
      if ($res2->{Success}) {
	push @items, $res2->{Result};
      }
    }
    return {
	    Success => 1,
	    Results => \@items,
	   };
  }
}

sub ClassifyLanguage {
  my ($self,%args) = @_;
  # for now
  return {
	  Text => $args{Text},
	  SourceLanguage => scalar langof($args{Text}),
	 };
}

sub PrimeMT {
  my ($self,%args) = @_;
  # find an engine for the language pair
  my $matches = {};
  foreach my $key (keys %{$self->Engines}) {
    my $engine = $self->Engines->{$key};
    if (exists $engine->{Pairs}) {
      if (exists $engine->{Pairs}->{$args{SourceLanguage}} and
	  exists $engine->{Pairs}->{$args{SourceLanguage}}->{$args{DestinationLanguage}}) {
	$matches->{$key}++;
      }
    }
    if (exists $engine->{Sources} and exists $engine->{Destinations}) {
      if (exists $engine->{Sources}->{$args{SourceLanguage}} and
	  exists $engine->{Destinations}->{$args{DestinationLanguage}}) {
	$matches->{$key}++;
      }
    }
  }
  my @sorted = sort {$self->Engines->{$b}->{Preference} <=> $self->Engines->{$a}->{Preference}} keys %$matches;
  my $engine;
  if (scalar @sorted) {
    $engine = shift @sorted;
  } else {
    $engine = "NULL";
  }
  if (! $self->MTs->{$engine}) {
    # eventually support several MTs like festival and mbrola
    # verify the existence of the module before using
    my $module = "ALL::MT::$engine";
    my $file = $module;
    $file =~ s/::/\//g;
    my $req = $UNIVERSAL::systemdir."/$file.pm";
    print $req."\n";
    require $req;
    my $item = "$module"->new
      (
       SourceLanguage => $args{SourceLanguage},
       DestinationLanguage => $args{DestinationLanguage},
      );
    $self->MTs->{$engine} = $item;
  }
  return {
	  Success => 1,
	  Result => $engine,
	 };
}

1;
