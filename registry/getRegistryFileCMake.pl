#!/bin/perl

use warnings;
use strict;
use SoftwareInformationsProvider;
use Data::Dumper;

my $sip = new SoftwareInformationsProvider();
my @programKey = $sip->getSoftwareRelatedKeys("CMake");
my $reg = $sip->generateRegFileContent(\@programKey);

print($reg);
