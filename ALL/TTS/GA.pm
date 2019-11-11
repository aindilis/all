package ALL::TTS::GA;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Net::Telnet;
use Text::Wrap;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / DataDir TTS Count Table1 Table2 / ];

sub init {
  my ($s,%a) = @_;
  $s->Count({});
  $s->Table1({});
  $s->Table2({});
  $s->DataDir("/var/lib/myfrdcsa/codebases/internal/all/data");
  $s->LoadPhoneticTable;
  $s->LoadPhoneticToPhenomeTable();
  # print Dumper($s->Table2);

  # # do this if there is no festival server running
  # system "festival --server &";
  # system "sleep 7";
  $tts = Net::Telnet->new(Timeout=>3600,
			  Errmode=>'die');
  $tts->open(Host => "localhost",
	     Port => "1314");
  $s->TTS($tts);
}

sub ShouldWorkForLanguage {
  my ($self,%args) = @_;
  if ($args{Language} eq "ga") {
    return {
	    Success => 1,
	    Output => 1,
	   };
  } else {
    return {
	    Success => 1,
	    Output => 0,
	   };
  }
}

sub LoadPhoneticTable {
  my ($s,%a) = @_;
  my @examples;
  my $datadir = $s->DataDir;
  foreach my $line (split /\n/, `cat $datadir/phonetics`) {
    if ($line =~ /^\s*\#/) {
      # comment
    } elsif ($line !~ /\S/) {
      # space
    } else {
      # print "<$line>\n";
      my ($spelling, $phonetic, $examples) = split /\t/, $line;
      my $scon = "";
      my $pcon = "";
      if ($spelling =~ /^(.+) \((.+)\)$/) {
	$spelling = $1;
	$scon = $2;
      }
      if ($phonetic =~ /^(.+) \"(.+)\"$/) {
	$phonetic = $1;
	$pcon = $2;
      }
      if ($phonetic =~ /^\/(.+)\/$/) {
	$phonetic = $1;
      } else {
	print "Phonetic error <$phonetic>\n";
      }
      my $e = [split /,\s*/, $examples];
      push @examples, @$e;
      foreach my $chars (split /,\s*/, $spelling) {
	$chars =~ s/\)/\)\?/g;
	$s->Table2->{$chars}->{$scon}->{$phonetic} = {
						  Phonetic => $phonetic,
						  PCon => $pcon,
						  Examples => $e,
						 };
      }
    }
  }
}

sub LoadPhoneticToPhenomeTable {
  my ($s,%a) = @_;
  my $datadir = $s->DataDir;
  foreach my $line (split /\n/, `cat $datadir/phonetic-to-phenome-table`) {
    if ($line =~ /^\#/) {
      # skip
    } elsif ($line =~ /^\s*$/) {
      # skip
    } else {
      # likely a valid line, process
      my ($symbol, $phenomesorphonetics, $comment) = split /\t/, $line;
      # process the thing, whether it is a phenomes or phonetics
      if ($phenomesorphonetics =~ /^\//) {
	my $phonetics = $phenomesorphonetics;
	# eliminate markers
	$phonetics =~ s/^\/(.*)\/$/$1/;
	my @possibilities = split /,\s*/, $phonetics;
	# just use the first one for now
	my $phonetic = shift @possibilities;
	my @res;
	foreach my $p (split /\s+/, $phonetic) {
	  if (exists $s->Table1->{$p}) {
	    push @res, @{$s->Table1->{$p}};
	  } else {
	    push @res, "<$p>";
	  }
	}
	$s->Table1->{$symbol} = \@res;
      } else {
	my $phenomes = $phenomesorphonetics;
	my @possibilities = split /,\s*/, $phenomes;
	# just use the first one for now
	my $phenome = shift @possibilities;
	$s->Table1->{$symbol} = [split /\s+/, $phenome];
      }
    }
  }
  # print Dumper($s->Table1);
}

sub TranslatePhoneticWordToPhenomeWord {
  my ($s,%a) = @_;
  my $pw = $a{PhoneticWord};
  my @w;
  foreach my $phonetic (@$pw) {
    if ($s->Table1->{$phonetic}) {
      push @w, @{$s->Table1->{$phonetic}};
    } else {
      push @w, "($phonetic)";
    }
  }
  return \@w;
}

sub TranslateWordToPhenomeWord {
  my ($s,%a) = @_;
  return $s->TranslatePhoneticWordToPhenomeWord
    (PhoneticWord =>
     $s->TranslateWordToPhoneticWord
     (Word => $a{Word}));
}

sub TranslateText {
  my ($s,%a) = @_;
  # split it into sentences and words and syllables
  my $sentences = get_sentences($a{Text});
  my @t;
  foreach my $sentence (@$sentences) {
    # get words and then translate them into
    my @s;
    foreach my $word (@{get_words($sentence)}) {
      push @s, {
		Word => $word,
		Phones => $s->TranslateWordToPhenomeWord
		(Word => $word),
	       };
    }
    push @t, {Text => $sentence,
	      Sentence => \@s};
  }
  return \@t;
}

sub Speak {
  my ($s,%a) = @_;
  my $tt = $s->TranslateText(Text => $a{Text});
  foreach my $sentence (@$tt) {
    print wrap('',"\t",$sentence->{Text})."\n";
    foreach my $word (@{$sentence->{Sentence}}) {
      my $phones = join(" ",map "\"$_\"", @{$word->{Phones}});
      my $c = "(utt.play (utt.synth (eval (list 'Utterance 'Phones (list $phones)))))";
      print "$c\n";
      $s->TTS->print($c);
      $s->TTS->waitfor(Match => '/ft_StUfF_keyOK/',
		    Timeout => 0.25,
		    Errmode => "return");
    }
    sleep 1;
  }
}

sub TranslateWordToPhoneticWord {
  my ($s,%a) = @_;
  return $s->GetOnePhoneticSpellingOfAWord(Word => $a{Word});
}

sub get_words {
  my $t = shift;
  return [split /\s/, $t];
}

sub getcount {
  my $k = shift;
  my $c = 0;
  foreach my $ch (split //, $k) {
    if ($ch eq "(") {
      ++$c;
    }
  }
  return $c;
}

sub GenerateAllPossibleParsesOfWord {
  my ($s,%a) = @_;
  my $word = $a{Word};
  # take this table2, and for now, don't apply the type checking, just match the spellings
  my @res;
  foreach my $key (keys %{$s->Table2}) {
    # how many parens does this regex have
    $s->Count->{$key} = getcount($key) if ! exists $count->{$key};
    if ($word =~ /^($key)(.*)/i) {
      my $count2 = $s->Count->{$key} + 2;
      my @send = @{$a{Current}};
      push @send, $1;
      if ($$count2) {
	push @res, @{$s->GenerateAllPossibleParsesOfWord
		       (Word => $$count2,
			Current => \@send)};
      } else {
	push @res, \@send;
      }
    }
  }
  return \@res;
}

# should add GetCorrectPhoneticSpellingOfAWord

sub GetOnePhoneticSpellingOfAWord {
  my ($s,%a) = @_;
  return $s->GetOnePhoneticSpellingOfABreakdown
    (Breakdown => $s->GetOneBreakdownOfAWord
     (Word => $a{Word}));
}

sub GetOneBreakdownOfAWord {
  my ($s,%a) = @_;
  my @res = @{$s->GetAllBreakdownsOfAWord
		(Word => $a{Word})};
  return shift @res;
}

sub GetAllBreakdownsOfAWord {
  my ($s,%a) = @_;
  return $s->GenerateAllPossibleParsesOfWord
    (Word => $a{Word}, Current => []);
}

sub GetOnePhoneticSpellingOfABreakdown {
  my ($s,%a) = @_;
  my @res = @{$s->GetAllPhoneticSpellingsOfABreakdown
		(Breakdown => $a{Breakdown})};
  return shift @res;
}

sub GetAllPhoneticSpellingsOfABreakdown {
  my ($s,%a) = @_;
  return $s->GenerateAllPhoneticSpellingsOfABreakdown
     (Breakdown => $a{Breakdown},
      Current => []);
}

sub GenerateAllPhoneticSpellingsOfABreakdown {
  my ($s,%a) = @_;
  my $b = $a{Breakdown};
  my $c = $a{Current};

  my @ret;
  if ($b and @$b) {
    my $chars = shift @$b;
    # find the matching keys
    my @matches;
    foreach my $key (keys %{$s->Table2}) {
      if ($chars =~ /$key/i) {
	foreach my $scon (keys %{$s->Table2->{$key}}) {
	  foreach my $phonetic (keys %{$s->Table2->{$key}->{$scon}}) {
	    my $mycur;
	    if ($phonetic eq "SILENT") {
	      $mycur = $c;
	    } else {
	      $mycur = [@$c,$phonetic];
	    }
	    push @ret, @{$s->GenerateAllPhoneticSpellingsOfABreakdown
			   (Breakdown => $b,
			    Current => $mycur)};
	  }
	}
      }
    }
  } else {
    push @ret, $c;
  }
  return \@ret;
}

sub CheckForInput {
  my ($self,%args) = @_;
#   #   my $res =  PidsForProcess
#   #     (
#   #      Process => "mp3-decoder",
#   #     );
#   #   print Dumper($res);
#   my $res = `ps aux | grep aplay | grep -v grep`;
#   chomp $res;
#   if ($res =~ /./) {
#     return "timeout";
#   } else {

#   }
}

1;
