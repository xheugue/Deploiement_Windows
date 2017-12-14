package Network::Discovering;

=pod

=head1 NAME

Network::Discovering - Permits you to create easily service for network discovering.

=head1 SYNOPSIS

  my $object = Network::Discovering->new(port => port);
  $object->serverLoop(awaitedMessage, answerMessage);
  
  $object->dummy;

=head1 DESCRIPTION

This module permits you to create easily a service which is able to discover the network using UDP protocol

=head1 METHODS

=cut

use strict;
use warnings;
use IO::Socket::INET;
use IO::Select;

our $VERSION = '0.01';

=pod

=head2 new

  my $object = Network::Discovering->new(
      port => 'port'
  );

The C<new> constructor lets you create a new B<Network::Discovering> object.

Returns a new B<Network::Discovering> or dies on error.

=cut

sub new{
		my @args = @_;
	
		die("Usage: $0 port") if (@args != 2);
	
		my ($class, $port) = @args;
		$class = ref($class) || $class;
		
		my $this = {};
		
		bless($this, $class);
		$this->{port} = $port;
		return $this;
}

=pod

=head2 serverLoop

$object->serverLoop(awaitedMessage, answerMessage);

This method does a loop and check for broadcast message.

=cut

sub serverLoop {
		my @args = @_;
		
		die("Usage: \$object->$0(recvMessage, ansMessage)") if (@args != 3);
		
		my ($this, $recvMessage, $ansMessage) = @args;
		
		my $listener = IO::Socket::INET->new(
				LocalPort => $this->{port},
				Proto => "udp"
		) or die("Unable to bind: $@\n");

		while (1) {
				my $msg;
				$listener->recv($msg, 4096);
				next if ($msg ne $recvMessage);
				my $peer_address = $listener->peerhost();
				my $peer_port = $listener->peerport();
				
				my $responder =  IO::Socket::INET->new(
						PeerAddr  => "$peer_address",
						PeerPort => "$peer_port",
						Proto => "udp",
				) or die("Unable to bind: $@\n");
				$responder->printflush($ansMessage);
				$responder->close();
		}
}

=pod

=head2 serverLoop

$object->serverLoop(message, awaitedMessage);

This method use the broadcast mechanism to look for machines on the server (need to have a service that answer on broadcast messages

=cut
sub discoverNetwork {
		my @args = @_;
		die ("Usage: \$object->discoverNetwork(yourMessage, theMessageAwaited, port_in)")  if (@args != 4);
		my ($this, $message, $awaitedMessage, $port_in) = @args;
		
		my $socket = IO::Socket::INET->new(
				PeerAddr  => "255.255.255.255",
				PeerPort => $this->{port},
				LocalPort => "$port_in",
				Proto => "udp",
				Broadcast => 1
		) or die("Unable to bind: $@\n");
		$socket->printflush($message);
		$socket ->close();
		
		$socket = IO::Socket::INET->new(
				LocalPort => "$port_in",
				Proto => "udp",
		) or die("Unable to bind: $@\n");
		my $address = $socket->sockhost();
		my @ip;
		while (1) {
				my $ans;
				my $sel = IO::Select->new($socket);
				if ($sel->can_read(5)) {
				    $socket->recv($ans, 4096);
			    }
				return @ip if (! $ans);
				next if ($ans ne $awaitedMessage);
 
				unshift(@ip, $socket->peerhost()) if ($address ne $socket->peerhost());
		}
}


1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
