#!/bin/perl

use warnings;
use strict;
use WebService;
use Data::Dumper;

print("Test Persistence : \n");
print("Liste programme\n");

my @softwareList = WebService::getComputerSoftwares();
print(Dumper(@softwareList));

my @deployedList = WebService::getDeployedSoftwares();
print(Dumper(@deployedList));

my @packageList = WebService::getInstalledPackage();
print(Dumper(@packageList));

print("Test Standalone\n");
WebService::installStandalone("GVim 8.0", "C:\\Program Files (x86)\\Vim", 1);
