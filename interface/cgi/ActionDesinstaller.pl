#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
print "Content-type: text/html; charset=iso-8859-1\n\n";
print "<phtml>";
print "<body>";
my @list= (15,'chaine',"bonjour");
print "$list[0]<br/>";
print "$list[1]<br/>";
print "$list[2]<br/>";
print "</body>";
print "</html>";
