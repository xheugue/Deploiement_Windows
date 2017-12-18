#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;
use CGI;

my $cgi = new CGI;
my $file = $cgi->param('param');
my $installsoftware = new WebService($file);
   $installsoftware->WebService::installSoftware();
print "
<html>
<body>";
print " Software installed "
print"
</body>
</html>
";

