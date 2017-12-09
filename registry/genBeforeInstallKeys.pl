#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use RegistryMonitoring;

my $softKey = new RegistryMonitoring("HKEY_LOCAL_MACHINE\\Software");
my $rootKey = new RegistryMonitoring("HKEY_CLASSES_ROOT");

$softKey->keySnapshot("soft.old.reg");
$rootKey->keySnapshot("root.old.reg");
