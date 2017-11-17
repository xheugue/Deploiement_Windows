#!/bin/perl

use warnings;
use strict;
use MSIExecutor;

my $installation = new MSIExecutor("dummy.msi");

$installation->uninstallMSI();
