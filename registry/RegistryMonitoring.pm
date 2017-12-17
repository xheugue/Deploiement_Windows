package Registry::RegistryMonitoring;

use strict;
use warnings;
use Win32::TieRegistry;
use Win32::TieRegistry qw(:KEY_ :REG_);
use Win32::Process;
use Win32;

=pod

=head1 NAME

Registry::RegistryMonitoring - A class that enable you to look at the differencies of keys

=head1 SYNOPSIS

my $object = Registry::RegistryMonitoring::new(keyPath);

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

my $object = Registry::RegistryMonitoring::new(keyPath)

The constructor of the monitor for a registry key

=over PARAMETERS
=item keyPath : The path of the registry key you want to monitored
=back

=cut

sub new {
    my @args = @_;
    
    if (@args != 2) {
        die("Usage: Registry::RegistryMonitoring::new(keyPath)");
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
    
    unshift(@arguments, "regdiff.exe", $regPath, "$regPath.new", "/4","/diff","$newPath.update.reg");
    Win32::Process::Create($process, "C:\\regdiff-4.3\\regdiff.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");
    
    $process->Wait(INFINITE);
    unlink("$regPath.new");
    
    return "$newPath.update.reg";
}

=pod

=head1 FUNCTION

=head2 CleanRegistries

Registry::RegistryMonitoring::CleanRegistries(keyName)

Remove all useless registry key

=cut

sub CleanRegistries {
    my @args = @_;
    
    die("Usage: $0 keyName") if (@args != 1);
    
    my ($keyName) = @args;
    
     my $registry = new Win32::TieRegistry("$keyName", { Access=>KEY_ALL_ACCESS() });
     
     return if (!defined($registry));
     
     my @valueNames = $registry->ValueNames();
     my @subkeyNames = $registry->SubKeyNames();
     
     if (@subkeyNames != 0) {
        for my $subkey (@subkeyNames) {
            Registry::RegistryMonitoring::CleanRegistries("$keyName\\$subkey");
        }
     }
     @valueNames = $registry->ValueNames();
     @subkeyNames = $registry->SubKeyNames();
     
     if (@subkeyNames == 0 && @valueNames == 0) {
        $registry->FastDelete(1);
     }
}

sub mergeDiff {
    my @args = @_;
    
    die("Usage: $0 regPath1 regPath2") if (@args != 2) ;
    
    my ($regPath, $regPath2) = @args;
    
    my $process;
    my @arguments;

    unshift(@arguments, "regdiff.exe", $regPath, "$regPath2", "/4","/merge","$regPath");
    Win32::Process::Create($process, "C:\\regdiff-4.3\\regdiff.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");
    
    $process->Wait(INFINITE);
}


=pod

=head2 GenerateInverseRegistry

Registry::RegistryMonitoring::CleanRegistries(regPath, inverseRegPath)

Generate the inverse registry file of regPath at inverseRegPath

=cut

sub GenerateInverseRegistry {
    my @args = @_;
    
    die("Usage: $0 regPath inverseRegPath") if (@args != 2) ;
    
    my ($regPath, $inverseRegPath) = @args;
    
    open(my $fh, "<", $regPath) || die("Cannot open $regPath");
    open(my $out, ">", $inverseRegPath) || die("Cannot open $regPath");
    
    while (my $line = <$fh>) {
            $line =~ s/^([^\n]+)=[^\n]+\n$/$1=""\n/g;
            $line =~ s/^ +[^\n]+\r?\n$//g if ($line =~ m/^ +[^\n]+\n$/g);
            print $out $line;
    }
    close($fh);
    close($out);
}

1;
