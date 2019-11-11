package ALL::TTS::AbairIE;

use PerlLib::Mechanize;

use Cache::FileCache;
use Data::Dumper;
use WWW::Mechanize::Cached;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyCacher /

  ];

sub init {
  my ($self,%args) = @_;
  my $timeout = 15;
  my $cacheobj = new Cache::FileCache
    ({
      namespace => 'abair-ie',
      default_expires_in => "2 years",
      cache_root => "/var/lib/myfrdcsa/codebases/internal/all/data/abairie/FileCache",
     });
  $self->MyCacher
    (WWW::Mechanize::Cached->new
     (
      cache => $cacheobj,
      timeout => $timeout,
     ));
}

sub ShouldWorkForLanguage {
  my ($self,%args) = @_;
  if ($args{Language} eq "ga") {
    # FIXME: check internet connectivity

    # FIXME: check site is live

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

sub Speak {
  my ($self,%args) = @_;
  my $url = "http://www.abair.tcd.ie/index.php?page=synthesis&lang=eng";
  $self->MyCacher->get($url);

  $self->MyCacher->form_number( 2 );
  $self->MyCacher->field("input",$args{Text});
  $self->MyCacher->click();

  my $downloadlink;
  foreach my $link ($self->MyCacher->links()) {
    if ($link->[1] eq "mp3 file") {
      $downloadlink = $link->url_abs->as_string;
      last;
    }
  }

  print $downloadlink."\n";
  my $file = $downloadlink;
  $file =~ s/.+\///;
  print $file."\n";
  my $dir = "/var/lib/myfrdcsa/codebases/internal/all/data/abairie/mp3s";
  my $filename = "$dir/$file";
  if (! -f $filename) {
    system "wget -nd -P /var/lib/myfrdcsa/codebases/internal/all/data/abairie/mp3s $downloadlink";
  }

  my $command = "mplayer $filename &";
  print $command."\n";
  system $command;
}

sub ShouldWork {

}

sub CheckForInput {
  my ($self,%args) = @_;
  #   my $res =  PidsForProcess
  #     (
  #      Process => "mplayer",
  #     );
  #   print Dumper($res);
  my $res = `ps aux | grep mplayer | grep -v grep`;
  chomp $res;
  if ($res =~ /./) {
    return "timeout";
  } else {

  }
}

1;
