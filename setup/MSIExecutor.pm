package MSIExecutor;

use strict;
use warnings;
use Win32::Process;
use Win32;

=begin pod

=head1 Synopsis

This module make you able to install and uninstall msi program with default parameter

=head1 Dependencies

This script work only on Windows, and need the following packages to work:

=over packages

=item Win32::Process
=item Win32

=back

=head1 Methods and Usage

=head2 new
Build an object to do the installations
Parameters: msiPath, the path to the msi file
Return: the created object. Think to check the value returned by this function

=head2 installMSI
Launch the MSI program in quiet mode for install
Parameters: none
Return: none

=head2 uninstallMSI
Launch the MSI program in quiet mode for uninstall
Parameters: none
Return: none

=cut

sub new {
    my @argu = @_;

    die("invalid number argument for MSI Building. Arg number" . @_ ) if (@argu != 2);
    my ($class, $prgPath) = @argu;

    die("The file does'nt exists") if (! -f $prgPath);
    
    die("The file is not a MSI file") if ($prgPath !~ m/^.+?\.msi$/);

    $class = ref($class) || $class;
    my $this = {};
    bless($this, $class);

    $this->{msi} = $prgPath;
    return $this;
}

sub installMSI {
    my @argu = @_;

    die("invalid number of argument for MSI installation") if (@argu != 1);
    my ($this) = @argu;

    my $processus;
    my @arguments;

    unshift(@arguments, "msiexec.exe", "/i", $this->{msi}, "/quiet", "/promptrestart");

    Win32::Process::Create($processus, "C:\\Windows\\system32\\msiexec.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");

    $processus->Wait(INFINITE);
}

sub uninstallMSI {
    my @argu = @_;

    die("invalid number of argument for MSI uninstall") if (@argu != 1);
    my ($this) = @argu;

    my $processus;
    my @arguments;

    unshift(@arguments, "msiexec.exe", "/x", $this->{msi}, "/quiet", "/promptrestart");

    Win32::Process::Create($processus, "C:\\Windows\\system32\\msiexec.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");

    $processus->Wait(INFINITE);
}

1;
