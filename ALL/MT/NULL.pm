package ALL::MT::NULL;

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

sub Translate {
  my ($self,%args) = @_;
  print "There is no engine for this language pair: ".$args{SourceLanguage}."-".$args{DestinationLanguage}."\n";
}

1;
