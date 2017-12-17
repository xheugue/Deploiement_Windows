#!C:\Perl64\bin\perl.exe

use DBI;
use CGI;
use IO::Socket::INET;
use WebService;

my $cgi = new CGI;
my $file = $cgi->param('FicherCharge');
my $installsoftware = new WebService($file);
   $installsoftware->WebService::getComputerSoftwares();



print "Content-Type: text/html\n\n";

#Corps de la page
print "
# <html>
<head>
<meta http-equiv=\"refresh\" content=\"0; URL='../framePack2.html'\" />
</head>
<body>
</body>
</html>
";
