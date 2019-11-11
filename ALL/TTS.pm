package ALL::TTS;

# use ALL::TTS::AbairIE;
# use ALL::TTS::EspeakMbrola;
# use ALL::TTS::GA;
# use ALL::TTS::NULL;

use Data::Dumper;
use Lingua::Identify qw(:language_identification);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / TTSes Langs Provides CurrentTTS /

  ];

sub init {
  my ($self,%args) = @_;
  $self->TTSes({});
  $self->Langs([
		{
		 "en" => 1,
		 "ca" => 1,
		},
		{
		 "es" => 1,
		 "ca" => 1,
		},
		{
		 "es" => 1,
		 "gl" => 1,
		},
		{
		 "es" => 1,
		 "pt" => 1,
		},
		{
		 "es" => 1,
		 "ro" => 1,
		},
		{
		 "fr" => 1,
		 "ca" => 1,
		},
	       ]);
  $self->Provides
    ({
      "la" => [
	       "EspeakMbrola",
	      ],
      "de" => [
	       "EspeakMbrola",
	      ],
      "es" => [
	       "EspeakMbrola",
	      ],
      "id" => [
	       "EspeakMbrola",
	      ],
      "fr" => [
	       "EspeakMbrola",
	      ],
      "en" => [
	       "Festival",
	       "EspeakMbrola",
	       "EN",
	      ],
      "ga" => [
	       "AbairIE",
	       "GA",
	      ],
     });
}

sub Speak {
  my ($self,%args) = @_;
  if (defined $args{Language}) {
    print Dumper({
		  Language => $args{Language},
		  Text => $args{Text},
		 }) if 0;
    # now speak it
    my $res = $self->PrimeTTS
      (
       Language => $args{Language},
      );
    # print Dumper({Res => $res});
    if ($res->{Success} and $res->{Result}) {
      $self->CurrentTTS($self->TTSes->{$args{Language}});
      $self->TTSes->{$args{Language}}->Speak
	(
	 Text => $args{Text},
	 Language => $args{Language},
	);
    } else {
      print "ALL::TTS does not support guessed language yet: <".$args{Language}.">\n";
    }
  } else {
    # classify the language first
    # need to break it down into multiple segments if necessary,
    # therefore annotate the text with the attributes
    foreach my $segment ($self->ClassifyLanguage(Text => $args{Text})) {
      # manage the various TTS
      $self->Speak
	(
	 Text => $segment->{Text},
	 Language => $segment->{Language} || "en",
	);
    }
  }
}

sub ClassifyLanguage {
  my ($self,%args) = @_;
  # for now
  return {
	  Text => $args{Text},
	  Language => scalar langof($args{Text}),
	 };
}

sub PrimeTTS {
  my ($self,%args) = @_;
  if (! $self->TTSes->{$args{Language}}) {
    if (exists $self->Provides->{$args{Language}}) {
      my $list = $self->Provides->{$args{Language}};
      foreach my $ttssystem (@$list) {
	my $part = $list->[0];
	# eventually support several TTSes like festival and mbrola
	# verify the existence of the module before using
	my $module = "ALL::TTS::$part";
	my $file = $module;
	$file =~ s/::/\//g;
	# replace this with a reference to the all system dir, so that
	# it is not hardcoded
	my $req = "/var/lib/myfrdcsa/codebases/internal/all/$file.pm";
	print "$req\n";
	if (-f $req) {
	  require $req;
	  my $item = "$module"->new(SystemDir => $UNIVERSAL::systemdir);
	  my $res = $item->ShouldWorkForLanguage(Language => $args{Language});
	  if ($res->{Success}) {
	    if ($res->{Result}) {
	      $self->TTSes->{$args{Language}} = $item;
	      last;
	    } else {
	      return $res;
	    }
	  } else {
	    return $res;
	  }
	}
      }
      if (! exists $self->TTSes->{$args{Language}}) {
	return {
		Success => 0,
		Reason => "ALL::TTS does not appear to be in working order for language <$args{Language}>, you probably need to install some software or debug the code.",
	       };
      } else {
	return {
		Success => 1,
		Result => 1,
	       };
      }
    } else {
      return {
	      Success => 0,
	      Reason => "ALL::TTS does not support guessed language yet: <".$args{Language}.">",
	     };
      # $self->TTSes->{$args{Language}} = ALL::TTS::NULL->new();
    }
  }
  return {
	  Success => 1,
	  Result => 1,
	 };
}

sub CheckForInput {
  my ($self,%args) = @_;
  if (defined $self->CurrentTTS) {
    return $self->CurrentTTS->CheckForInput();
  }
  return "unknown";
}

1;
