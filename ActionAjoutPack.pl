#!C:\Perl64\bin\perl.exe

use DBI;
use CGI;
use IO::Socket::INET;
use WebService;

my $cgi = new CGI;
my $file = $cgi->param('FicherCharge');
my $folder = $cgi->param('folder');
my $nomPackage = $cgi->param('nomPackage');

if (($file eq '' && $folder eq '') || ($file ne '' && $folder ne '')) {
    print "Content-Type: text/html\n\n";
    print "Veuillez définir, soit le fichier, soit le dossier.";
    
    }

    my $emplacement = (defined($folder) ? $folder : $file);
    my $registry = (! $cgi->param("registry") ? 0 : 1);
my $installsoftware = new WebService($file);
    $installsoftware->WebService::installStandalone($nomPackage, $emplacement, $registry);

print "Content-Type: text/html\n\n";

#Corps de la page
print "
# <html>
<head>(defined($file) && defined($folder)) || (! defined($file) && ! defined($folder))
<meta http-equiv=\"refresh\" content=\"0; URL='../framePack2.html'\" />
</head>
<body>
</body>
</html>
";
