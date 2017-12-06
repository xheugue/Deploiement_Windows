package InstallPackage;

use Archive::Zip;

=pod

=head1 NAME

InstallPackage - Class to install some stuff on Windows machine

=head1 SYNOPSIS

  my $object = InstallPackage->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->initialize(dir, name, dest);
  $object->createPackage(name, dest);
  $object->installPackage();

=head1 DESCRIPTION

This class permits to create some package using existing folder on the machine, or installing it using a zip file

=head1 METHODS

=cut

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

=pod

=head2 initialize

  my $object = InstallPackage->initialize(
      dir => 'path to dir',
      name => 'name of the package',
      dest => 'destination of the package'
  );

The C<initialize> constructor lets you initializing a new B<InstallPackage> object.


Returns a new B<InstallPackage> for a creation or dies on error.

=cut

sub initialize {
	my @args = @_;
	
	if (@_ != 4) {
		die ("Usage: InstallPackage->initialize(pathToDirToPack, name, dest)");
	}
	
	my ($class, $dir, $name, $dest) = @args;
	
	$class = ref($class) || $class;
	my $this = {};
	
	bless($this, $class);
	
		$this->{dir} = $dir;
	$this->{name} = $name;
	$this->{dest} = $dest;
	
		return $this;
}

=pod

=head2 prepare

  my $object = InstallPackage->initialize(
      name => 'name of the package',
      dest => 'destination of the package'
  );

The C<prepare> constructor lets you create a new B<InstallPackage> object.

Returns a new B<InstallPackage> for an installation or dies on error.

=cutsub prepare {
	my @args = @_;
	
	if (@_ != 3) {
		die ("Usage: InstallPackage->prepare(pathToPackage, installDestination)");
	}
	
	my ($class, $name, $dest) = @args;
	
	$class = ref($class) || $class;
	my $this = {};
	
	bless($this, $class);
	
	$this->{name} = $name;
	$this->{dest} = $dest;
	
	return $this;}

=pod

=head2 createPackage

$object->createPackage()

This method create the package, save it, and add an entry to the database

=cut

sub createPackage {
    my @args = @_;
    
    if (@args != 1) {
	die("Usage : \$object->installPackage");
    }
    
    my ($this) = @args;
    
    if (! defined($this->{dir})) {
    	die("This package is already created");
    }
    
    my $package = Archive::Zip->new($this->{name});
    
    $package->addDirectory($this->{dir});
    
    if ( $zip->writeToFileNamed('C:\\SoftwarePackage\\' . $this->{name}) != AZ_OK ) {
    	die ("Impossible to save the package");
    }
    
    # Ecriture d'informations sur la BDD
}

=pod

=head2 installPackage

$object->installPackage()

This method install the package to the specified destination, located in the database
=cutsub installPackage {
    my @args = @_;
    
    if (@args != 1) {
	die("Usage : \$object->installPackage");
    }
    
    my ($this) = @args;
    
        my $zip;
    my $dest;
    # Lecture grace a BDD
    
    $zip->extractToFileNamed($dest);
    
    return 1;}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
