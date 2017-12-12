#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Registry::RegistryMonitoring;

# Informations logiciels
my $softKey = new RegistryMonitoring("HKEY_LOCAL_MACHINE\\Software");

# Association extension-fichier et menu contextuels
my $starRootKey = new RegistryMonitoring("HKEY_CLASSES_ROOT\\*");

# Information sur les services
my $servicesKey = new RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services");

# Informations de demarrage
my $controlsKey = new RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control");

# enumere les drivers
my $enumKey = new RegistryMonitoring("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Enum");

############################################################
### Enregistrement des instantanees de cles systemes
############################################################
$softKey->keySnapshot("soft.old.reg") if (! -f "soft.old.reg");
$starRootKey->keySnapshot("star_root.old.reg") if (! -f "star_root.old.reg");
$servicesKey->keySnapshot("service.old.reg") if (! -f "service.old.reg");
$controlsKey->keySnapshot("controls.old.reg") if (! -f "controls.old.reg");

