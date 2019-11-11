#!/usr/bin/perl -w

# this is a version that allows emacs to view the stuff while
# executing code in emacs remotely to do a search and replace

# objectionable phrase

use Data::Dumper;
use Manager::Dialog qw(Approve);

my $from = shift;
my $to = shift;

my $find = `find . | xargs grep -i "$from"`;

my $files;
foreach my $line (split /\n/, $find) {
    if ($line =~ /^(.*?):/) {
	$files->{$1} = 1;
    }
}

foreach my $file (sort keys %$files) {
  if (Approve("$file")) {
    system "/usr/bin/emacsclient.emacs-snapshot $file -e '(and (find-file \"$file\") (query-replace \"$from\" \"$to\"))'";
  }
}
