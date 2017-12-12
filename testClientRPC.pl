#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use RPC::XML;
use RPC::XML::Client;
use Data::Dumper;

my $client = RPC::XML::Client->new("http://192.168.0.2:9000");

my $resp = $client->send_request("createAndSendPackage", "GIMP 2.8.22");
print "Error: " . Dumper($resp);