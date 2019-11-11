package ALL;

use ALL::MT;
use ALL::TTS;
use BOSS::Config;
use MyFRDCSA;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config MyTTS MyMT / ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	--mt				Translate Text
	--tts				Speak Text
	--mt-tts			Translate then Speak Text

	-t <text>			Source Text
	-s <language>			Source Language (for TTS, MT)
	-d <language>			Destination Language (for MT)

	-u [<host> <port>]		Run as a UniLang agent
";
  $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"all");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'--tts'}) {
    $self->Speak
      (
       Text => $conf->{'-t'},
       Language => $conf->{'-s'},
      ),
  }
  if (exists $conf->{'--mt'}) {
    $self->Translate
      (
       Text => $conf->{'-t'},
       SourceLanguage => $conf->{'-s'},
       DestinationLanguage => $conf->{'-d'},
      );
  }
  if (exists $conf->{'--mt-tts'}) {
    # first translate, then speak text
    $self->TranslateAndSpeak
      (
       Text => $conf->{'-t'},
       SourceLanguage => $conf->{'-s'},
       DestinationLanguage => $conf->{'-d'},
      );
  }
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    # process the args in very much the same fashion as the regular args
    # for now, just do something simple
    if ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    } elsif ($it =~ /^speak (.+)$/i) {
      $self->Speak
	(
	 Text => $1,
	);
    } elsif ($it =~ /^translate (\w+) (.+)$/i) {
      $self->Translate
	(
	 Text => $2,
	 DestinationLanguage => $1,
	);
    } elsif ($it =~ /^translate and speak (\w+) (.+)$/i) {
      $self->TranslateAndSpeak
	(
	 Text => $2,
	 DestinationLanguage => $1,
	);
    }
  }
  if ($m->Data) {
    print Dumper($m->Data);
    my $command = $m->Data->{Command};
    my $text = $m->Data->{Text};
    if ($command =~ /^speak$/i) {
      $self->Speak
	(
	 Text => $text,
	 Language => $m->Data->{SourceLanguage},
	);
    } elsif ($command =~ /^translate$/i) {
      # send a response here
      print Dumper
	($self->Translate
	 (
	  Text => $text,
	  DestinationLanguage => $m->Data->{DestinationLanguage},
	 ));
    } elsif ($command =~ /^translate and speak$/i) {
      $self->TranslateAndSpeak
	(
	 Text => $text,
	 DestinationLanguage => $m->Data->{DestinationLanguage},
	);
    }
  }
}

sub Speak {
  my ($self,%args) = @_;
  print "Reading: ".$args{Text}."\n";
  $self->MyTTS(ALL::TTS->new) if ! $self->MyTTS;
  $self->MyTTS->Speak
    (
     Text => $args{Text},
     Language => $args{Language},
    );
}

sub Translate {
  my ($self,%args) = @_;
  print "Translating: ".$args{Text}."\n";
  $self->MyMT(ALL::MT->new) if ! $self->MyMT;
  return $self->MyMT->Translate
    (
     Text => $args{Text},
     SourceLanguage => $args{SourceLanguage},
     DestinationLanguage => $args{DestinationLanguage},
    );
}

sub TranslateAndSpeak {
  my ($self,%args) = @_;
  $self->MyMT(ALL::MT->new) if ! $self->MyMT;
  my $res = $self->Translate
    (
     Text => $args{Text},
     SourceLanguage => $args{SourceLanguage},
     DestinationLanguage => $args{DestinationLanguage},
    );
  if ($res->{Success}) {
    $self->Speak
      (
       Text => $res->{Text},
       Language => $args{DestinationLanguage},
      );
  }
  return $res;
}

1;
