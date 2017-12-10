#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use InstallPackage;

my $package = InstallPackage->prepare("dummy.zip", "testExtraction/");

$package->installPackage();
