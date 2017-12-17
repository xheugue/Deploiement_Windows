package Registry::RegistryInstaller;

use warnings;
use strict;
use Win32::Process;
use Win32;
use File::Glob ':glob';
=pod

=cut

sub new {
    my @args = @_;
    
    if (@args != 2) {
        die("Invalid number of arguments");
    }
    
    if ( ! -d $args[1]) {
	die("The argument is not a directory");
    }
    
    my ($class, $dir) = @args;
    
    $class = ref($class) || $class;
    
    my $this = {};
    bless($this, $class);
    $this->{dir} = $dir;
    
    return $this;}

=pod

=cut
sub applyRegFiles {
    my @args = @_;
    
    if (@args != 1) {
	die("This function must be called from an object");
    }
    
    my ($this) = @args;
    
    if ($this->{dir} !~ m@\\$@) {
	$this->{dir} .= "\\";
    }
    
    my @regFiles = bsd_glob($this->{dir} . "*.reg");
    
    for my $regFile (@regFiles) {
	my @arguments;
	my $process;
	unshift(@arguments, "reg.exe", "import", "\"$regFile\"");
	Win32::Process::Create($process, "C:\\Windows\\system32\\reg.exe", join(" ", @arguments), 0, NORMAL_PRIORITY_CLASS, ".");
	$process->Wait(INFINITE);
    }
}

1;