#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Network::Discovering;

my $server = Network::Discovering->new("9001");
$server->serverLoop("Decouverte UDP ?", "J'en suis");