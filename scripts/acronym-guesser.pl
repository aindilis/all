#!/usr/bin/perl -w

# given an acronym and some context, this system attempts to define it

# first try various acronym databases

# if that fails, do repeated google queries and run acronym extraction
# software on the results


# in the future have some way to autocompose this work flow

use System::ExtractAbbrev;

use Data::Dumper;

my $ea = System::ExtractAbbrev->new();

print Dumper($ea->ExtractAbbrev
  (Text =>
   'In computer programming, FTBFS stands for "Fails To Build From Source". It describes the situation where source code cannot be compiled to machine code, ...'
));
