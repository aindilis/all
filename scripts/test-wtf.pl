#!/usr/bin/perl -w
use PerlLib::SwissArmyKnife;

print Dumper({PackagesInstalled => PackagesInstalled(Packages => ['festival','emacs24'])});
print Dumper({PackagesInstalled => PackagesInstalled(Packages => ['festival','emacs24','bleating-goat'])});
