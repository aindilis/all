package ALL::MT::Apertium;

use System::Apertium;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyApertium /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyApertium
    (System::Apertium->new);
}

sub Translate {
  my ($self,%args) = @_;
  my $res = $self->TranslateBetweenPairs
    (
     Text => $args{Text},
     From => $args{SourceLanguage},
     To => $args{DestinationLanguage},
    );
  if ($res->{Result} eq "success") {
    return {
	    Success => 1,
	    Result => $res->{Contents},
	   };
  } else {
    return {
	    Success => 0,
	    Reasons => $res,
	   };
  }
}

1;
