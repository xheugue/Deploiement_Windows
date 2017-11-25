#!/bin/perl

use warnings;
use strict;
use SoftwareInformationsProvider;
use Data::Dumper;

my $sip = new SoftwareInformationsProvider();
my @programKey = $sip->getSoftwareRelatedKeys("CMake");

print Dumper(@programKey);
