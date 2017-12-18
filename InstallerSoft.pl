#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;
use CGI;

my $cgi = new CGI;
my $nom = $cgi->param('param');
WebService::installSoftware($nom);
print "
<html>
<body>";
print " Software installed ";
print"
</body>
</html>
";

