#!/usr/bin/perl -w

use PerlLib::Mechanize;

use Cache::FileCache;
use Data::Dumper;
use WWW::Mechanize::Cached;

my $timeout = 15;

my $cacheobj = new Cache::FileCache
  ({
    namespace => 'abair-ie',
    default_expires_in => "2 years",
    cache_root => "/var/lib/myfrdcsa/codebases/internal/all/data/abairie/FileCache",
   });

my $cacher = WWW::Mechanize::Cached->new
  (
   cache => $cacheobj,
   timeout => $timeout,
  );

my $url = "http://www.abair.tcd.ie/index.php?page=synthesis&lang=eng";
$cacher->get($url);

$cacher->form_number( 2 );
$cacher->field("input",$ARGV[0]);
$cacher->click();

my $downloadlink;
foreach my $link ($cacher->links()) {
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

my $command = "mp3-decoder $filename";
print $command."\n";
system $command;
