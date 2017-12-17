#!/bin/perl

use warnings;
use strict;
use WebService;
use Data::Dumper;

print("Test Remove : \n");
WebService::removePackage("GVim 8.0");
WebService::removePackage("Microsoft Visual Studio Code");
