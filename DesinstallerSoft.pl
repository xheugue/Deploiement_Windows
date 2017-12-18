#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;


my @installedpakages=WebService::getInstalledPackage();
#Corps de la page
print "
<html>
<body>";
#print"$t";
print"
 <table border=\"1\">";
print"
<table border=\"1\">
  <th>Liste des packages</th>";
  for(my $i = 0 ; $i < @installedpakages ; $i++){
  print "<tr><td align=\"center\">$installedpakages[$i]</td>";
  print "
        <center>
    			<td>
    				<form action=\"SupprimerPack.pl?param=".$installedpakages[$i]."\"	enctype=\"multipart/form-data\" 
              method=\"post\" value=\"install".$installedpakages[$i]."\">
      				<div>
        				<input type=\"submit\" value=\"Supprimer\">
      				</div>
    				</form>
    			</td>
        </center>
  		";
  }
print "</tr></table>";

print"
</body>
</html>
";

