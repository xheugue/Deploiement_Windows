#!/bin/perl

use strict;
use warnings;
use FTPClient;

my $clientFTP = new FTPClient("192.168.0.3", "admin", "password");

$clientFTP->sendDir("C:\\Program Files\\CMake");
