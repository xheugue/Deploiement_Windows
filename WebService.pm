package WebService;

=pod

=head1 NAME

WebService - My author was too lazy to write an abstract

=head1 SYNOPSIS
  WebService::getComputerSoftwares()
  WebService::getDeployedSoftwares()
  WebService::getInstalledPackage()
  WebService::installSoftware(nom)
  WebService::installStandalone(nom, emplacement, needRegistry, [destination])
  WebService::removePackage(nom)
  WebService::updateSoftware(nom)

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 FUNCTIONS

=cut

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

=pod

=head2 getComputerSoftwares

This method return the list of the install softwares which can be deployed

=cut

sub getComputerSoftwares{
	die("Not implemented");
}

=pod

=head2 getDeployedSoftwares

This method return the list of the softwares which have been deployed

=cut

sub getDeployedSoftwares {
	die("Not implemented");
}

=pod

=head2 getInstalledPackage

This method return the list of package which have been deployed on the computer park
=cut

sub getInstalledPackage {
		die("Not implemented");
}
=pod

=head2 installSoftware

This method install the software indicate by its name
=cut
sub installSoftware {
    die("Not implemented");
}

=pod

=head2 installStandalone

This method create a package and install it using its location, name, destination and generate registry files if needed

=cutsub installStandalone {
    die("Not implemented");
}
=pod

=head2 removePackage

This method remove the package indicate by its name

=cut
sub removePackage {
    die("Not implemented");
}
=pod

=head2 installSoftware

This method update the software indicate by its name

=cut
sub updateSoftware {
    die("Not implemented");
}


1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
