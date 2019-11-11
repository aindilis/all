package ALL::TTS::NULL;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw /  /

  ];

sub init {
  my ($self,%args) = @_;

}

sub ShouldWorkForLanguage {
  return {
	  Success => 1,
	  Output => 1,
	 };
}

sub Speak {
  my ($self,%args) = @_;
  my $lang = $args{Language};
  print "This language ($lang) not implemented yet!\n";
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
