package SoftwareInformationsProvider;

use strict;
use warnings;
use Win32::TieRegistry;
use Win32::TieRegistry qw(:KEY_ :REG_);
use Data::Dumper;
use Switch;

=begin pod

=head1 Synopsis

=head1 Dependencies

=over packages
=item Win32API::Registry
=item Win32::TieRegistry
=item Switch
=back

=head1 Methods and Usage

=head2 new

Initialize the SoftwareInformationsProvider

Parameters : None
Return : An instance of SoftwareInformationsProvider

=begin comment

_listSoftwareInSubkeys permits to list softwares in a subkey
Parameters: subkeyName, reference to the array to complete
Return : none

=end comment

=head2 getSoftwareList()

Provide an array reference to the list of installed software

Parameters: None
Return : An array which contains the list of installed software

=head2 getSoftwareRelatedKeys()

Provide an array of key path related to a software

Parameters: displayName, the display name of the software
Return: A key list related to the software

=cut

sub new {
    my @args = @_;

    die ("Not enough parameters For SoftwateInformationsProvider initialization") if (@args != 1);

    my ($class) = @args;

    $class = ref($class) || $class;

    my $this = {};

    bless($this, $class);

    $this->{keys} = new Win32::TieRegistry("HKEY_LOCAL_MACHINE\\Software", { Access=>KEY_READ() });
    return $this;
}

sub _createFromKey {
    my @args = @_;

    die ("Not enough parameters For SoftwareInformationsProvider initialization") if (@args != 3);

    my ($class, $key, $subkey) = @args;

    $class = ref($class) || $class;

    my $this = {};

    bless($this, $class);

    $this->{keys} = $key->Open($subkey, { Access=>KEY_ALL_ACCESS });;
    return $this;
}

sub _listSoftwareInSubkeys {
    my @args = @_;

    die ("Not enough parameters to list software's subkey") if (@args != 1);

    my ($this) = @args;

    my @subkeyNames = $this->{keys}->SubKeyNames();
    my @program;

    foreach my $keyName (@subkeyNames) {
        my $subkey = _createFromKey SoftwareInformationsProvider($this->{keys}, $keyName);

        if (! defined($subkey->{keys})) {
            next;
        }
        my @valueNames = $subkey->{keys}->ValueNames();

        my @filteredAttribute = grep(m/DisplayName/, @valueNames);

        if (@filteredAttribute == 1) {
            my ($value, $type) = $subkey->{keys}->GetValue("DisplayName");
            unshift(@program, $value);
        } else {
            next;
        }
    }

    return @program;
}

sub getSoftwareList {
    my @args = @_;

    die ("Not enough parameters to get the software list") if (@args != 1);

    my ($this) = @args;

    my $subkey = _createFromKey SoftwareInformationsProvider($this->{keys}, "Microsoft\\Windows\\CurrentVersion\\Uninstall");
    my @programs = $subkey->_listSoftwareInSubkeys();
    my $program = \@programs;
    return $program;
}

sub _getKeyPathByDisplayName {
    my @args = @_;

    die ("Not enough parameters to get the software list") if (@args != 2);

    my ($this, $displayname) = @args;

    my @subkeyNames = $this->{keys}->SubKeyNames();
    my @program;

    foreach my $keyName (@subkeyNames) {
        my $subkey = _createFromKey SoftwareInformationsProvider($this->{keys}, $keyName);

        if (! defined($subkey->{keys})) {
            next;
        }

        my @valueNames = $subkey->{keys}->ValueNames();

        my @filteredAttribute = grep(m/DisplayName/, @valueNames);

        if (@filteredAttribute == 1) {
            my ($value) = $subkey->{keys}->GetValue("DisplayName");

            if ($value eq $displayname) {
                return $subkey->{keys}->Path;
            }
        } else {
            next;
        }
    }
    return undef;
}

sub _searchKeysWithKeyName {
    my @args = @_;

    die ("Not enough parameters to get the software list") if (@args != 3);

    my ($this, $keyName, $displayname) = @args;

    my @subkeys = $this->{keys}->SubKeyNames();

    my @keys;

    foreach my $subkeyName (@subkeys) {
        if ($subkeyName =~ m/($displayname|$keyName)/gi) {
            push(@keys, $this->{keys}->Path . $subkeyName);
        }

        my $subkey = _createFromKey SoftwareInformationsProvider($this->{keys}, $subkeyName);

        if (! defined($subkey->{keys})) {
            next;
        }
=begin comment
        my @valueNames = $subkey->{keys}->ValueNames();
        my $isIn = undef;

        foreach my $valueName (@valueNames) {
            if ( ($valueName =~ m/($displayname|$keyName)/gi) && ! defined($isIn)) {
                push(@keys, $subkey->{keys}->Path);
                $isIn = 1;
            }
        }
=cut
        if ($subkey->{keys}->SubKeyNames() != 0) {
            push(@keys, $subkey->_searchKeysWithKeyName($keyName, $displayname));
        }
    }
    return @keys;
}

sub getSoftwareRelatedKeys {
    my @args = @_;

    die ("Not enough parameters to get the software list") if (@args != 2);

    my ($this, $displayname) = @args;

    my $uninstaller = _createFromKey SoftwareInformationsProvider($this->{keys}, "Microsoft\\Windows\\CurrentVersion\\Uninstall");

    my $keyPath = $uninstaller->_getKeyPathByDisplayName($displayname);

    my ($keyName) = $keyPath =~ m/[^\\]+?\\$/g;

    my $backslash = chop($keyName);

    my @list = $this->_searchKeysWithKeyName($keyName, $displayname);

    return @list;
}

sub generateRegFileContent {
    my @args = @_;

    die ("Not enough parameters to generate the registry file") if (@args != 2);

    my ($this, $list) = @args;

    die("Usage: $0 reference_to_list") if (ref($list) ne "ARRAY");

    my $reg = "Windows Registry Editor Version 5.00";

    my @copyList = @$list;

    foreach my $keyPath (@copyList) {
        my $key =  _createFromKey SoftwareInformationsProvider($this->{keys}, $keyPath);

        if (! defined($key->{keys})) {
            next;
        }

        $keyPath =~ s/^\\//;
        $reg .= "\n\n[$keyPath]\n";

        foreach my $valueName ($key->{keys}->ValueNames()) {
            my ($value, $typeValue) = $key->{keys}->GetValue($valueName);
            my $type;

            switch($typeValue) {
                case REG_BINARY() {$type = "hexadecimal";}
                case REG_DWORD() {$type = "dword";}
                case REG_EXPAND_SZ() {$type = "hexadecimal(2)";}
                case REG_SZ() {$type = "None";}
                case REG_MULTI_SZ() {$type = "hexadecimal(7)";}

            }


            if ($type ne "None" ) {
                $reg .= "\n\"$valueName\"=$type:$value"; 
            } else {
                $reg .= "\n\"$valueName\"=\"$value\"";
            }
        }
    }

    return $reg;
}

1;
