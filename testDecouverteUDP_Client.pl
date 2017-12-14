#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Network::Discovering;
use Data::Dumper;

my $server = Network::Discovering->new("8000");
my @ip = $server->discoverNetwork("Are you a software installer?", "Yes i'm a software installer", "8001");

print(Dumper(@ip)."\n");
