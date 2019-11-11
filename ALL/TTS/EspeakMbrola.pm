package ALL::TTS::EspeakMbrola;

use Data::Dumper;
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Languages Voices /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Voices
    ({
      "af" => {
	       "1" => {
		       "Espeak" => "mb-af1",
		       "Mbrola" => "/usr/share/mbrola/voices/af1",
		      },
	      },
      "br" => {
	       "3" => {
		       "Espeak" => "mb-br3",
		       "Mbrola" => "/usr/share/mbrola/voices/br3",
		      },
	      },
      "cr" => {
	       "1" => {
		       "Espeak" => "mb-cr1",
		       "Mbrola" => "/usr/share/mbrola/voices/cr1",
		      },
	      },
      "cz" => {
	       "2" => {
		       "Espeak" => "mb-cz2",
		       "Mbrola" => "/usr/share/mbrola/voices/cz2",
		      },
	      },
      "de" => {
	       "6" => {
		       "Espeak" => "mb-de6",
		       "Mbrola" => "/usr/share/mbrola/voices/de6",
		      },
	       "7" => {
		       "Espeak" => "mb-de7",
		       "Mbrola" => "/usr/share/mbrola/voices/de7",
		      },
	      },
      "en" => {
	       "1" => {
		       "Espeak" => "mb-en1",
		       "Mbrola" => "/usr/share/mbrola/voices/en1",
		      },
	      },
      "es" => {
	       "1" => {
		       "Espeak" => "mb-es1",
		       "Mbrola" => "/usr/share/mbrola/voices/es1",
		      },
	      },
      "fr" => {
	       "4" => {
		       "Espeak" => "mb-fr4",
		       "Mbrola" => "/usr/share/mbrola/voices/fr4",
		      },
	      },
      "gr" => {
	       "2" => {
		       "Espeak" => "mb-gr2",
		       "Mbrola" => "/usr/share/mbrola/voices/gr2",
		      },
	      },
      "hu" => {
	       "1" => {
		       "Espeak" => "mb-hu1",
		       "Mbrola" => "/usr/share/mbrola/voices/hu1",
		      },
	      },
      "id" => {
	       "1" => {
		       "Espeak" => "mb-id1",
		       "Mbrola" => "/usr/share/mbrola/voices/id1",
		      },
	      },
      "it" => {
	       "3" => {
		       "Espeak" => "mb-it3",
		       "Mbrola" => "/usr/share/mbrola/voices/it3",
		      },
	       "4" => {
		       "Espeak" => "mb-it4",
		       "Mbrola" => "/usr/share/mbrola/voices/it4",
		      },
	      },
      "la" => {
	       "1" => {
		       "Espeak" => "mb-la1",
		       "Mbrola" => "/usr/share/mbrola/voices/la1",
		      },
	      },
      "nl" => {
	       "2" => {
		       "Espeak" => "mb-nl2",
		       "Mbrola" => "/usr/share/mbrola/voices/nl2",
		      },
	      },
      "pl" => {
	       "1" => {
		       "Espeak" => "mb-pl1",
		       "Mbrola" => "/usr/share/mbrola/voices/pl1",
		      },
	      },
      "pt" => {
	       "1" => {
		       "Espeak" => "mb-pt1",
		       "Mbrola" => "/usr/share/mbrola/voices/pt1",
		      },
	      },
      "ro" => {
	       "1" => {
		       "Espeak" => "mb-ro1",
		       "Mbrola" => "/usr/share/mbrola/voices/ro1",
		      },
	      },
      "sw" => {
	       "1" => {
		       "Espeak" => "mb-sw1",
		       "Mbrola" => "/usr/share/mbrola/voices/sw1",
		      },
	       "2" => {
		       "Espeak" => "mb-sw2",
		       "Mbrola" => "/usr/share/mbrola/voices/sw2",
		      },
	      },
      "us" => {
	       "1" => {
		       "Espeak" => "mb-us1",
		       "Mbrola" => "/usr/share/mbrola/voices/us1",
		      },
	       "2" => {
		       "Espeak" => "mb-us2",
		       "Mbrola" => "/usr/share/mbrola/voices/us2",
		      },
	      },
     });
}

sub ShouldWorkForLanguage {
  my ($self,%args) = @_;
  # FIXME: ProgramInPath(Program => 'mbrola');
  my $res1 = PackagesInstalled(Packages => ['mbrola']);
  if ($res1->{Success}) {
    if ($res1->{Result}) {
      if ($args{Language} eq 'en') {
	return PackagesInstalled(Packages => ['mbrola-en1']
      } elsif ($args{Language} eq 'djkfasdlfsd') {
	return {
		Success => 1,
		Result => 0,
		Reason => ''
	       };
      } else {
	return {
		Success => 1,
		Result => 0,
		Reason => ''
	       };
      }
    } else {
      return $res1;;
    }
  } else {
    return $res1;
  }
}

sub Speak {
  my ($self,%args) = @_;

  #   Type => "Espeak-Mbrola",
  #     MbrolaVoice => "/usr/share/mbrola/voices/".$mbrolavoice,
  #       EspeakVoice => $voice,

  my $lang = $args{Language};
  if (exists $self->Voices->{$lang}) {
    my @keys = sort keys %{$self->Voices->{$lang}};
    my $first = shift @keys;
    my $voices = $self->Voices->{$lang}->{$first};
    chomp $args{Text};
    $string = shell_quote $args{Text};
    system "espeak -v ".$voices->{Espeak}." ".$string." | mbrola -e ".$voices->{Mbrola}." - - | aplay -r16000 -fS16 1> /dev/null 2> /dev/null &";
  } else {
    print "Language ($lang) not yet supported by this EspeakMbrola module\n";
  }
}

sub CheckForInput {
  my ($self,%args) = @_;
  #   my $res =  PidsForProcess
  #     (
  #      Process => "mp3-decoder",
  #     );
  #   print Dumper($res);
  my $res = `ps aux | grep aplay | grep -v grep`;
  chomp $res;
  if ($res =~ /./) {
    return "timeout";
  } else {

  }
}

1;
