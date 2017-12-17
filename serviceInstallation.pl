#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Network::FTPClient;
use Network::Discovering;

use RPC::XML::Server;
use RPC::XML::Procedure;
use RPC::XML::Client;

use Registry::RegistryMonitoring;
use Registry::RegistryInstaller;
use Registry::SoftwareInformationsProvider;

use Package::InstallPackage;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

use DBI;

use threads;
use threads::shared;

use File::Glob ':glob';
use File::Path;
use File::Copy;

my $ftp :shared = 1;
my $register :shared = 1;
my $db :shared = 1;

mkdir("C:\\software_package") if (! -d "C:\\software_package");
mkdir("C:\\msis") if (! -d "C:\\msis");

if (! -f  "parcinfo.db") {
      my $dbh = DBI->connect(          
      "dbi:SQLite:dbname=parcinfo.db", 
      "",
      "",
      { RaiseError => 1}
  ) or die $DBI::errstr;
    $dbh->do("CREATE TABLE packageNormal(idpackage INTEGER PRIMARY KEY AUTOINCREMENT,nompackage VARCHAR (255), localisation VARCHAR(255) , destination VARCHAR (255), type VARCHAR(255),installed BOOL DEFAULT FALSE)");
    $dbh->disconnect();
}

sub registerPackageInDatabase {
     my @args = @_;
     die("Usage: $0 nomPackage localisation destination type [TRUE|FALSE]") if (@args < 4 || @args > 5);
     
     lock($db);
     {
         my $dbh = DBI->connect(          
                "dbi:SQLite:dbname=parcinfo.db", 
                "",
                "",
                { RaiseError => 1}
          ) or die $DBI::errstr;
         
         my ($nom, $localisation, $destination, $type,$installed) = @args;
         $installed = (defined($installed) ? $installed : "FALSE");
         my $stmt = $dbh->prepare("INSERT INTO PackageNormal(nomPackage, localisation,destination, installed, type) VALUES (?, ?, ?, ?,?)");
         my @args = ($nom, "$localisation", $destination, "$installed", "software");
         $stmt->execute(@args);
         $stmt->finish();
         $dbh->disconnect();
     }
}

sub generateReg {
    lock($register);
     # Informations logiciels
        my $softKey = Registry::RegistryMonitoring->new("HKEY_LOCAL_MACHINE\\Software");

        # Association extension-fichier et menu contextuels
        my $starRootKey = Registry::RegistryMonitoring->new("HKEY_CLASSES_ROOT\\*");

        # Information sur les services
        my $servicesKey = Registry::RegistryMonitoring->new("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services");

        # Informations de demarrage
        my $controlsKey = Registry::RegistryMonitoring->new("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control");

        # enumere les drivers
        my $enumKey = Registry::RegistryMonitoring->new("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Enum");

        ############################################################
        ### Enregistrement des instantanees de cles systemes
        ############################################################
        $softKey->keySnapshot("soft.old.reg");
        $starRootKey->keySnapshot("star_root.old.reg");
        $servicesKey->keySnapshot("services.old.reg");
        $controlsKey->keySnapshot("controls.old.reg");
        $enumKey->keySnapshot("enum.old.reg");
}

sub cleanRegistries {
    lock($register);
     Registry::RegistryMonitoring::CleanRegistries("HKEY_LOCAL_MACHINE\\Software");
     Registry::RegistryMonitoring::CleanRegistries("HKEY_CLASSES_ROOT\\*");
     Registry::RegistryMonitoring::CleanRegistries("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services");
     Registry::RegistryMonitoring::CleanRegistries("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control");
     Registry::RegistryMonitoring::CleanRegistries("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Enum");
}

sub makeDiff {
    lock($register);
     my $softKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\Software");
     my $starRootKey = new Registry::RegistryMonitoring("HKEY_CLASSES_ROOT\\*");
     my $servicesKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services");
     my $controlsKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control");
     my $enumKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Enum");
     my $softDiff = $softKey->diffWithSnapshot("soft.old.reg");
     my $starDiff = $starRootKey->diffWithSnapshot("star_root.old.reg");
     my $servicesDiff = $servicesKey->diffWithSnapshot("services.old.reg");
     my $controlsDiff = $controlsKey->diffWithSnapshot("controls.old.reg");
     my $enumDiff = $enumKey->diffWithSnapshot("enum.old.reg");
     return ($softDiff, $starDiff, $servicesDiff, $controlsDiff, $enumDiff);
}

sub createAndSendStandalone {
     my @args = @_;
    die("Invalid number of arguments") if (@args < 3 || @args > 4);
    my ($nom, $emplacement, $registry, $destination) = @args;
    $destination = (defined($destination) ? $destination : $emplacement);
    my $type;
    
    if (! -f "C:\\software_package\\$nom.zip") {
        
        if (-d $emplacement) {
            my $package = Package::InstallPackage->initialize($emplacement, "C:\\software_package\\$nom.zip");
            $package->createPackage();
        } elsif (-f $emplacement) {
            my $zip = Archive::Zip->new();
            $zip->addFile($emplacement);
            if ($zip->writeToFileNamed("C:\\software_package\\$nom.zip") != AZ_OK ) {
                die ("Impossible to save the package");
            }
        } else {
                die("The file doesn't exist");
        }
        if ($registry == 1) {
            {
                my ($softDiff, $starDiff, $servicesDiff, $controlsDiff, $enumDiff) = makeDiff();
                my $zip = Archive::Zip->new("C:\\software_package\\$nom.zip");
                $zip->addFile($softDiff);
                $zip->addFile($starDiff);
                $zip->addFile($servicesDiff);
                $zip->addFile($controlsDiff);
                $zip->addFile($enumDiff);
                
                if ( $zip->overwrite() != AZ_OK ) {
                    die ("Impossible to save the package");
                }
                
                copy($softDiff, $destination);
                copy($starDiff, $destination);
                copy($servicesDiff, $destination);
                copy($controlsDiff, $destination);
                copy($enumDiff, $destination);
                
                unlink($softDiff);
                unlink($starDiff);
                unlink($servicesDiff);
                unlink($controlsDiff);
                unlink($enumDiff);
                
                generateReg();
                $type = "software";
            }
        } else {
                $type = "standalone";
        }
        registerPackageInDatabase($nom, "C:\\software_package\\$nom.zip", $destination, "$type", "TRUE");
    }
    my $discover = Network::Discovering->new("8000");
    my @ip = $discover->discoverNetwork("Are you a software installer?", "Yes i'm a software installer", "8001");

        for my $cli (@ip) {
            lock($ftp);
            my $ftpClient = new Network::FTPClient("$cli", "admin", "password");
            $ftpClient->sendFile("C:\\software_package\\$nom.zip");
        
            my $client = RPC::XML::Client->new("http://$cli:9000");
            $client->send_request("registerPackageInDatabase", $nom, "C:\\software_package\\$nom.zip", $destination);
             $client->send_request("installPackage", "C:\\software_package\\$nom.zip", $destination);
        }
}

sub createAndSendPackage {

    my @args = @_;
    die("Invalid number of arguments") if (@args < 1 || @args > 2);
    my ($name, $update) = @args;
    $update = defined($update) ? $update : 0;
    
    my $sip = Registry::SoftwareInformationsProvider->new();
    my $sipForProgram = Registry::SoftwareInformationsProvider->createFromKey($sip->{keys}, "Microsoft\\Windows\\CurrentVersion\\Uninstall");
    my $regKeyPath = $sipForProgram->getKeyPathByDisplayName($name);
    my $registry = new Win32::TieRegistry($regKeyPath);
        
        my $installLocation = $registry->GetValue("InstallLocation");
        die("Impossible d'installer le programme de cette maniere") if (! defined($installLocation));
        my $installSource = $registry->GetValue("InstallSource");
        
        ($installLocation =~ m@\\([^\\]+)\\$@);
        
        my $folder = $1;
        
        if (! -f "C:\\software_package\\$folder.zip") {
            {
                my $package = Package::InstallPackage->initialize($installLocation, "C:\\software_package\\$folder.zip");
                $package->createPackage();
                registerPackageInDatabase($name, "C:\\software_package\\$folder.zip", $installLocation, "software", "TRUE");
            }
            {
                my ($softDiff, $starDiff, $servicesDiff, $controlsDiff, $enumDiff) = makeDiff();
                my $zip = Archive::Zip->new("C:\\software_package\\$folder.zip");
                $zip->addFile($softDiff);
                $zip->addFile($starDiff);
                $zip->addFile($servicesDiff);
                $zip->addFile($controlsDiff);
                $zip->addFile($enumDiff);
                
                if ( $zip->overwrite() != AZ_OK ) {
                    die ("Impossible to save the package");
                }
                
                copy($softDiff, $installLocation);
                copy($starDiff, $installLocation);
                copy($servicesDiff, $installLocation);
                copy($controlsDiff, $installLocation);
                copy($enumDiff, $installLocation);
                
                unlink($softDiff);
                unlink($starDiff);
                unlink($servicesDiff);
                unlink($controlsDiff);
                unlink($enumDiff);
                
                generateReg();
            }
        } elsif ($update == 1) {
            my ($softDiff, $starDiff, $servicesDiff, $controlsDiff, $enumDiff) = makeDiff();
            my $zip = Archive::Zip->new("C:\\software_package\\$folder.zip");
            Registry::RegistryMonitoring::mergeDiff( $softDiff, "$installLocation\\$softDiff");
            Registry::RegistryMonitoring::mergeDiff($starDiff, "$installLocation\\$starDiff");
            Registry::RegistryMonitoring::mergeDiff($servicesDiff, "$installLocation\\$servicesDiff");
            Registry::RegistryMonitoring::mergeDiff($controlsDiff, "$installLocation\\$controlsDiff");
            Registry::RegistryMonitoring::mergeDiff($enumDiff, "$installLocation\\$enumDiff");
            $zip->addFile($softDiff);
                $zip->addFile($starDiff);
                $zip->addFile($servicesDiff);
                $zip->addFile($controlsDiff);
                $zip->addFile($enumDiff);
                
                if ( $zip->overwrite() != AZ_OK ) {
                    die ("Impossible to save the package");
                }
                
                copy($softDiff, $installLocation);
                copy($starDiff, $installLocation);
                copy($servicesDiff, $installLocation);
                copy($controlsDiff, $installLocation);
                copy($enumDiff, $installLocation);
                
                unlink($softDiff);
                unlink($starDiff);
                unlink($servicesDiff);
                unlink($controlsDiff);
                unlink($enumDiff);
                
                generateReg();
        }
 
        my $discover = Network::Discovering->new("8000");
        my @ip = $discover->discoverNetwork("Are you a software installer?", "Yes i'm a software installer", "8001");

        for my $cli (@ip) {
            lock($ftp);
            my $ftpClient = new Network::FTPClient("$cli", "admin", "password");
            $ftpClient->sendDir($installSource) if (defined($installSource));
            $ftpClient->sendFile("C:\\software_package\\$folder.zip");
        
            my $client = RPC::XML::Client->new("http://$cli:9000");

            $client->send_request("registerPackageInDatabase", $name, "C:\\software_package\\$folder.zip", $installLocation);
            $client->send_request("installPackage", "C:\\software_package\\$folder.zip", $installLocation);
        }
}

sub installPackage {
    my @args = @_;
    die("Invalid number of arguments") if (@args != 2);
    
    my ($path, $dest) = @args;
    
    {
        lock($register);
        my $pkg = Package::InstallPackage->prepare($path, $dest);
        rmtree($dest) if (-d $dest);
        $pkg->installPackage();
        
        my $registryInstaller = Registry::RegistryInstaller->new($dest);
        $registryInstaller->applyRegFiles();
         generateReg();
    }
}

sub uninstallPackage {
    my @args = @_;
    die("Invalid number of arguments") if (@args != 1);
    my ($localisation, $destination);
    my ($nomPackage) = @args;
    
    {
          lock($db);
          my $dbh = DBI->connect(          
                "dbi:SQLite:dbname=parcinfo.db", 
                "",
                "",
                { RaiseError => 1}
          ) or die $DBI::errstr;
         
         my $stmt = $dbh->prepare("SELECT localisation,destination FROM packageNormal WHERE type=? AND nomPackage=?");
         $stmt->execute(("software", $nomPackage));
        my @row = $stmt->fetchrow_array;
        $localisation = $row[0];
        $destination = $row[1];

         if (! defined($localisation)) {
                die("Unknown package $nomPackage");
         }
         $stmt->finish();
         $dbh->disconnect();
    }
    
    my @regfiles = bsd_glob($destination . "*.reg");
    my $i = 0;
    for my $regs (@regfiles) {
        my $deletePath = ($regs =~ s/\.reg//rg);
        $deletePath .= ".delete.reg";
        Registry::RegistryMonitoring::GenerateInverseRegistry($regs, $deletePath);
        $i++;
        unlink($regs);
    }
            my $registryInstaller = Registry::RegistryInstaller->new($destination);
            $registryInstaller->applyRegFiles();
         {
              lock($db);
              my $dbh = DBI->connect(          
                    "dbi:SQLite:dbname=parcinfo.db", 
                    "",
                    "",
                    { RaiseError => 1}
              ) or die $DBI::errstr;
             
             my $stmt = $dbh->prepare("DELETE FROM packageNormal WHERE type=? AND nomPackage = ?");
             $stmt->execute(("software", $nomPackage));
             $stmt->finish();
         $dbh->disconnect();
        }
        cleanRegistries();
        generateReg();
        unlink("C:\\software_package\\$nomPackage.zip");
        rmtree($destination);
}

sub uninstallOnNetwork {
    my @args = @_;
    die("Invalid number of arguments") if (@args != 1);
    my ($nom) = @args;
    my $discover = Network::Discovering->new("8000");
        my @ip = $discover->discoverNetwork("Are you a software installer?", "Yes i'm a software installer", "8001");

        for my $cli (@ip) {
            my $client = RPC::XML::Client->new("http://$cli:9000");

            $client->send_request("uninstallPackage", $nom);
        }
        uninstallPackage($nom);
}

sub _uninstallOnNetwork {
    my @args = @_;
    die("Invalid number of arguments") if (@args != 1);
    my ($nom) = @args;
    my $thr1 = threads->create(\&uninstallOnNetwork, $nom);
}

sub _uninstallPackage {
    my @args = @_;
    die("Invalid number of arguments") if (@args != 1);
    my ($nom) = @args;
    my $thr1 = threads->create(\&uninstallPackage, $nom);
}

sub _installPackage {
    my $arg1 = shift;
    my $arg2 = shift;
    my $thr1 = threads->create(\&installPackage, $arg1, $arg2);
}

sub _createAndSendPackage {
    my $arg = shift;
    my $thr1 = threads->create(\&createAndSendPackage, $arg);
}

sub _createAndSendStandalone {
    my @args = @_;
    die("Invalid number of arguments") if (@args < 3 || @args > 4);
    my ($nom, $emplacement, $registry, $destination) = @args;
    my $thr1 = threads->create(\&createAndSendStandalone, $nom, $emplacement, $registry, $destination);
}


generateReg();
my $udpServer = Network::Discovering->new("8000");
my $serverThr = threads->create(sub { $udpServer->serverLoop("Are you a software installer?", "Yes i'm a software installer"); });
my $server = RPC::XML::Server->new(port => 9000);
my $fctInstall = RPC::XML::Function->new(name => "installPackage", code => \&_installPackage);
my $fctPackage = RPC::XML::Function->new(name => "createAndSendPackage", code => \&_createAndSendPackage);
my $fctUninstall = RPC::XML::Function->new(name => "uninstallPackage", code => \&_uninstallPackage);
my $fctUninstallNet = RPC::XML::Function->new(name => "uninstallOnNetwork", code => \&_uninstallOnNetwork);
my $fctStandalone = RPC::XML::Function->new(name => "createAndSendStandalone", code => \&_createAndSendStandalone);
my $fctDB= RPC::XML::Function->new(name => "registerPackageInDatabase", code => \&registerPackageInDatabase);
$server->add_method($fctInstall);
$server->add_method($fctPackage);
$server->add_method($fctStandalone);
$server->add_method($fctUninstall);
$server->add_method($fctUninstallNet);
$server->add_method($fctDB);
$server->server_loop();

$_->join() for threads->list();
