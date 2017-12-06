#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use InstallPackage;

my $package = InstallPackage->initialize("dummy", "Dummy", "dummy.zip");

$package->createPackage();
