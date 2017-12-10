#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use RegistryMonitoring;
use File::Copy;

my $softKey = new RegistryMonitoring("HKEY_LOCAL_MACHINE\\Software");
my $rootKey = new RegistryMonitoring("HKEY_CLASSES_ROOT");

$softKey->diffWithSnapshot("soft.old.reg");
$rootKey->diffWithSnapshot("root.old.reg");
