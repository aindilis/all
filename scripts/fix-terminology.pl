#!/usr/bin/perl -w

# objectionable phrase

my $objphrase = shift;

my $replacement = shift;

my $search = join(" ",@ARGV);
my $files = `find | xargs grep -i "$objphrase"`;

my @filestofix;
# print $files."\n";
foreach my $line (split /\n/, $files) {
    if ($line =~ /^(.*?):/) {
	push @filestofix, $1;
    }
}

foreach my $file (@filestofix) {
    my $c = `cat "$file"`;
    $c =~ s/$objphrase/$replacement/ig;
    my $OUT;
    open(OUT, ">$file") or die "can't\n";
    print OUT $c;
    close(OUT);
}
