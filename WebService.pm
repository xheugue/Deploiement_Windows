package WebService;

use strict;
use warnings;
use DBI;
use RPC::XML::Client;
use Registry::SoftwareInformationsProvider;

sub getComputerSoftwares {
	my $sip = new Registry::SoftwareInformationsProvider();
    my @programList = $sip->getSoftwareList();
    my @deployedList = getDeployedSoftwares();
    my @finalList = ();
    
    for my $prg (@programList) {
        my $in = 1;
        for my $deployed (@deployedList) {
            $in = 0 if ($prg eq $deployed);
        }
        unshift(@finalList, $prg) if ($in == 1);
    }
    return @finalList;
}

sub getDeployedSoftwares {
	my $dbh = DBI->connect(          
                "dbi:SQLite:dbname=parcinfo.db", 
                "",
                "",
                { RaiseError => 1}
          ) or die $DBI::errstr;
         
         my $stmt = $dbh->prepare("SELECT nomPackage FROM packageNormal WHERE type=?");
         $stmt->execute(("software"));
         
        my @prgList = ();
         while (my @row = $stmt->fetchrow_array) {
             unshift(@prgList, $row[0]);    
         }
         $stmt->finish();
         $dbh->disconnect();
         return @prgList;
}

sub getInstalledPackage {
		my $dbh = DBI->connect(
                "dbi:SQLite:dbname=parcinfo.db", 
                "",
                "",
                { RaiseError => 1}
          ) or die $DBI::errstr;
         
         my $stmt = $dbh->prepare("SELECT nomPackage FROM packageNormal");
         $stmt->execute();
                  
        my @prgList = ();
         while (my @row = $stmt->fetchrow_array)
         {
             unshift(@prgList, $row[0]);    
         }
         
         $stmt->finish();
         $dbh->disconnect();
         return @prgList;
}

sub installSoftware {
    my @args = @_;
    die("Usage: $0 (name)") if (@args != 1);
    my ($name) = @args;
    my $client = RPC::XML::Client->new("http://localhost:9000");
    $client->send_request("createAndSendPackage", $name);
}

sub installStandalone {
    my @args = @_;

    die("Usage: $0 (nom, emplacement, needRegistry, [destination])") if(@args < 3 || @args > 4);
    my ($name, $emplacement, $needRegistry, $destination) = @args;
    $destination = defined($destination) ? $destination : $emplacement;
    my $client = RPC::XML::Client->new("http://localhost:9000");
    $client->send_request("createAndSendStandalone", $name, $emplacement, $needRegistry, $destination);
}

sub removePackage {
    my @args = @_;

    die("Usage: $0 (nom") if (@args != 1);
    my ($name) = @args;
    my $client = RPC::XML::Client->new("http://localhost:9000");
    $client->send_request("uninstallOnNetwork", $name);
}

sub updateSoftware {
    my @args = @_;

    die("Usage: $0 (name)") if (@args != 1);
    my ($name) = @args;
    my $client = RPC::XML::Client->new("http://localhost:9000");
    $client->send_request("createAndSendPackage", $name, 1);
}

1;
