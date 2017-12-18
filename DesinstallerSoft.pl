#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;
use CGI;

my $cgi = new CGI;
my $file = $cgi->param('param');
WebService::removePackage($file);
   
   print "
   <html>
   <body>";
   print " Software uninstalled "
   print"
   </body>
   </html>
   ";   
