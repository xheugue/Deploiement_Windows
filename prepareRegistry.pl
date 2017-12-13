#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use RPC::XML::Server;
use RPC::XML::Procedure;
use RPC::XML::Client;

use Registry::RegistryMonitoring;
use Registry::RegistryInstaller;
use Registry::SoftwareInformationsProvider;

use Network::FTPClient;

use Package::InstallPackage;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

use threads;
use threads::shared;

my $ftp :shared = 1;
my $register :shared = 1;

# Informations logiciels
my $softKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\Software");

# Association extension-fichier et menu contextuels
my $starRootKey = new Registry::RegistryMonitoring("HKEY_CLASSES_ROOT\\*");

# Information sur les services
my $servicesKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services");

# Informations de demarrage
my $controlsKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control");

# enumere les drivers
my $enumKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Enum");

############################################################
### Enregistrement des instantanees de cles systemes
############################################################
$softKey->keySnapshot("soft.old.reg");
$starRootKey->keySnapshot("star_root.old.reg");
$servicesKey->keySnapshot("services.old.reg");
$controlsKey->keySnapshot("controls.old.reg");
$enumKey->keySnapshot("enum.old.reg");

mkdir("C:\\software_package") if (! -d "C:\\software_package");

sub createAndSendPackage {
    my @args = @_;
    die("Invalid number of arguments") if (@args != 1);
    my ($name) = @args;
    
    my $sip = Registry::SoftwareInformationsProvider->new();
    my $sipForProgram = Registry::SoftwareInformationsProvider->createFromKey($sip->{keys}, "Microsoft\\Windows\\CurrentVersion\\Uninstall");
    my $regKeyPath = $sipForProgram->getKeyPathByDisplayName($name);
    my $registry = new Win32::TieRegistry($regKeyPath);
    
        # TODO: UDP Broadcast
        
        my $installLocation = $registry->GetValue("InstallLocation");
        die("Impossible d'installer le programme de cette maniere") if (! defined($installLocation));
        my $installSource = $registry->GetValue("InstallSource");
        
        ($installLocation =~ m@\\([^\\]+)\\$@);
        
        my $folder = $1;
        
        if (! -f "C:\\software_package\\$folder.zip") {
            {
                my $package = Package::InstallPackage->initialize($installLocation, "C:\\software_package\\$folder.zip");
                $package->createPackage();
            }
            {
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
                my $zip = Archive::Zip->new("C:\\software_package\\$folder.zip");
                $zip->addFile($softDiff);
                $zip->addFile($starDiff);
                $zip->addFile($servicesDiff);
                $zip->addFile($controlsDiff);
                $zip->addFile($enumDiff);
                
                if ( $zip->overwrite() != AZ_OK ) {
                    die ("Impossible to save the package");
                }
                
                unlink($softDiff);
                unlink($starDiff);
                unlink($servicesDiff);
                unlink($controlsDiff);
                
                $softKey->keySnapshot("soft.old.reg");
                $starRootKey->keySnapshot("star_root.old.reg");
                $servicesKey->keySnapshot("services.old.reg");
                $controlsKey->keySnapshot("controls.old.reg");
                $enumKey->keySnapshot("enum.old.reg");
            }
        }
 

        {
            lock($ftp);
            my $ftpClient = new Network::FTPClient("192.168.0.3", "admin", "password");
            $ftpClient->sendFile($installSource) if (defined($installSource));
            $ftpClient->sendFile("C:\\software_package\\$folder.zip");
        
            my $client = RPC::XML::Client->new("http://192.168.0.3:9000");

            my $resp = $client->send_request("installPackage", "C:\\software_package\\$folder.zip", $installLocation);
            print "Error: $resp";
        }
}

sub installPackage {
    my @args = @_;
    die("Invalid number of arguments") if (@args != 2);
    
    my ($path, $dest) = @args;
    
    {
        lock($register);
        my $pkg = Package::InstallPackage->prepare($path, $dest);
        $pkg->installPackage();
        
        my $registryInstaller = Registry::RegistryInstaller->new($dest);
        $registryInstaller->applyRegFiles();
        # Informations logiciels
        my $softKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\Software");

        # Association extension-fichier et menu contextuels
        my $starRootKey = new Registry::RegistryMonitoring("HKEY_CLASSES_ROOT\\*");

        # Information sur les services
        my $servicesKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services");

        # Informations de demarrage
        my $controlsKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control");

        # enumere les drivers
        my $enumKey = new Registry::RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Enum");

        ############################################################
        ### Enregistrement des instantanees de cles systemes
        ############################################################
        $softKey->keySnapshot("soft.old.reg");
        $starRootKey->keySnapshot("star_root.old.reg");
        $servicesKey->keySnapshot("services.old.reg");
        $controlsKey->keySnapshot("controls.old.reg");
        $enumKey->keySnapshot("enum.old.reg");
    }
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

my $server = RPC::XML::Server->new(port => 9000);
my $fctInstall = RPC::XML::Function->new(name => "installPackage", code => \&_installPackage);
my $fctPackage = RPC::XML::Function->new(name => "createAndSendPackage", code => \&_createAndSendPackage);
$server->add_method($fctInstall);
$server->add_method($fctPackage);

$server->server_loop();

$_->join() for threads->list();
