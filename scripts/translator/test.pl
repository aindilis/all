#!/usr/bin/perl -w

use Data::Dumper;
use Net::Dict;

$dict = Net::Dict->new('localhost');
$h = $dict->define("eagraigh");
print Dumper($h);


