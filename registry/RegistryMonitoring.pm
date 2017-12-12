package Registry::RegistryMonitoring;

use strict;
use warnings;
use Win32::TieRegistry;
use Win32::TieRegistry qw(:KEY_ :REG_);
use Win32::Process;
use Win32;

=pod

=head1 NAME

RegistryMonitoring - A class that enable you to look at the differencies of keys

=head1 SYNOPSIS

my $object = RegistryMonitoring::new(keyPath);

=head1 DEPENDENCIES

=over packages
=item Win32
=item Win32::Process
=item Win32::TieRegistry
=item Win32API::Registry
=back

=head1 DESCRIPTION

This class enable you to create a monitor that can check registry key by a difference system between two installation, all you need
is to create keys before any operation performed on the system.

=head1 METHODS

=head2 new

my $object = RegistryMonitoring::new(keyPath)

The constructor of the monitor for a registry key

=over PARAMETERS
=item keyPath : The path of the registry key you want to monitored
=back

=cut

sub new {
    my @args = @_;
    
    if (@args != 2) {
        die("Usage: RegistryMonitoring::new(keyPath)");
    }
    
    my ($class, $keyPath) = @args;
    
    $class = ref($class) || $class;
    
    my $registryKey = new Win32::TieRegistry($keyPath, { Access=>KEY_READ() }) || die("Impossible to access to $keyPath");
    
    my $this = {};
    
    bless($this, $class);
    
    $this->{keyPath} = $keyPath;
    
    return $this;
}

=pod

=head2 keySnapshot

Take a snapshot of your key and register it as the file name specified in parameters

$object->keySnapshot("example.reg")

=over PARAMETERS
=item path The path to register the reg file
=back

=cut
sub keySnapshot {
    my @args = @_;
    
    if (@args != 2) {
        die ("Usage: \$object->keySnapshot(pathToYourRegFile)");
    }
    
    my ($this, $regPath) = @args;
    
    my $process;
    my @arguments;
    
    unshift(@arguments, "reg.exe", "export", $this->{keyPath}, $regPath, "/y");
    Win32::Process::Create($process, "C:\\Windows\\system32\\reg.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");
    
    $process->Wait(INFINITE);
}

=pod

=head2 diffWithSnapshot

Compare the actual state of the key with a reg file and give the differences between those two points

$object->diffWithSnapshot(path)

=over PARAMETERS
=item path The path of the snapshot to use for comparison.
=back

=cut

sub diffWithSnapshot {
    my @args = @_;
    
    if (@args != 2) {
        die ("Usage: \$object->keySnapshot(pathToYourRegFile)");
    }
    
    my ($this, $regPath) = @args;
    
    my $process;
    my @arguments;

    unshift(@arguments, "reg.exe", "export", $this->{keyPath}, "$regPath.new", "/y");
    Win32::Process::Create($process, "C:\\Windows\\system32\\reg.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");
    
    $process->Wait(INFINITE);
    
    @arguments = ();
    my $newPath = ($regPath =~ s/\.reg//r);
    
    unshift(@arguments, "regdiff.exe", $regPath, "$regPath.new", "/diff", "$newPath.update.reg");
    Win32::Process::Create($process, "C:\\regdiff-4.3\\regdiff.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");
    
    $process->Wait(INFINITE);
    unlink("$regPath.new");
    
    return "$newPath.update.reg";
}

1;
