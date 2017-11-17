#!/bin/perl

use warnings;
use strict;
use SoftwareInformationsProvider;
use Data::Dumper;

my $sip = new SoftwareInformationsProvider();
my $programList = $sip->getSoftwareList();

print Dumper(@$programList);
print "program list size = " . scalar(@$programList) . "\n";

