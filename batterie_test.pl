#!/bin/perl

use warnings;
use strict;
use Data::Dumper;

use WebService;

print("Test Computer Software Listing : \n");
my @softwareList = WebService::getComputerSoftwares();
print(Dumper(@softwareList));

print("Test Installation:\n");
WebService::installSoftware("Microsoft Visual Studio Code");

