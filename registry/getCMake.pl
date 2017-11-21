#!/bin/perl

use strict;
use warnings;
use FTPClient;

my $clientFTP = new FTPClient("localhost", "login", "password");

$clientFTP->getDir("C:\...\CMake");
