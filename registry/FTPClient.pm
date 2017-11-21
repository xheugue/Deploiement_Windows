package FTPClient;

use strict;
use warnings;
use Cwd;
use Net::FTP::Recursive;

sub _WinPathToFTP {
    my @args = @_;

    die("Usage: $0 Object ") if (@args != 1);

    my ($path) = @args;

    $path =~ s/\\/\//g;
    $path =~ s/C://;

    return $path;
}

sub new {
    my @args = @_;

    die("Usage: $0 host login password ") if (@args != 4);

    my ($class, $host, $login, $pass) = @args;

    $class = ref($class) || $class;

    my $this = {};

    bless($this, $class);

    $this->{ftp} = new Net::FTP::Recursive($host, Passive => 1) or die("Impossible to connect to the host : $host");

    $this->{ftp}->login($login, $pass) or die("Unable to authentify");

    return $this;
}

sub DESTROY {
    my @args = @_;

    die("Usage: $0 Object ") if (@args != 1);

    my ($this) = @args;

    $this->{ftp}->quit() if (defined($this->{ftp}));
}

sub sendDir {
    my @args = @_;

    die("Usage: $0 Object ") if (@args != 2);

    my ($this, $dir) = @args;

    die ("The directory $dir doesn't exist") if (! -d $dir);

    my $old = getcwd();

    chdir($dir);

    my $dest = _WinPathToFTP($dir);
    $this->{ftp}->mkdir($dest, 1);
    $this->{ftp}->cwd($dest);
    $this->{ftp}->rput();
    $this->{ftp}->cwd();

    chdir($old);
}

sub rmdir {
    my @args = @_;

    die("Usage: $0 Object ") if (@args != 2);

    my ($this, $dir) = @args;

    $dir = _WinPathToFTP($dir);

    $this->{ftp}->rmdir($dir, 1)
}

sub getDir {
    my @args = @_;

    die("Usage: $0 Object ") if (@args != 2);

    my ($this, $dir) = @args;

    die ("The directory $dir doesn't exist") if (! -d $dir);

    $this->{ftp}->get($dir, $dir);
}

1;