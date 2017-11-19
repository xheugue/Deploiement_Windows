package SoftwareInformationsProvider;

use strict;
use warnings;
use Win32::TieRegistry;
use Win32::TieRegistry qw(:KEY_);
use Data::Dumper;

=begin pod

=head1 Synopsis

=head1 Dependencies

=over packages
=item Win32API::Registry
=item Win32::TieRegistry
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

sub _searchKeysWithKeyNameAndKeyValues {
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

        my @valueNames = $subkey->{keys}->ValueNames();
        my $isIn = undef;

        foreach my $valueName (@valueNames) {
            if (( ($valueName =~ m/($displayname|$keyName)/gi) || ($subkey->{keys}->GetValue($valueName) =~ m/($displayname|$keyName)/gi) ) && ! defined($isIn)) {
                push(@keys, $subkey->{keys}->Path);
                $isIn = 1;
            }
        }
        if ($subkey->{keys}->SubKeyNames() != 0) {
            push(@keys, $subkey->_searchKeysWithKeyNameAndKeyValues($keyName, $displayname));
        }
    }
    return @keys;
}

sub getSoftwareRelatedKeys {
    my @args = @_;

    die ("Not enough parameters to get the software list") if (@args != 2);

    my ($this, $displayname) = @args;

    my $subkey = _createFromKey SoftwareInformationsProvider($this->{keys}, "Microsoft\\Windows\\CurrentVersion\\Uninstall");

    my $keyPath = $subkey->_getKeyPathByDisplayName($displayname);

    my ($keyName) = $keyPath =~ m/[^\\]+?\\$/g;

    my $backslash = chop($keyName);

    return $this->_searchKeysWithKeyNameAndKeyValues($keyName, $displayname);
}

1;
