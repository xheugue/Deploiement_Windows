#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;


my @installedsoftwares=WebService::getComputerSoftwares();
#Corps de la page
print "
<html>
<body>";
#print"$t";
print"
<table border=\"1\">
  <th>Liste des programme installés</th>";
  for(my $i = 0 ; $i < @installedsoftwares ; $i++){
  print "<tr><td align=\"center\">$installedsoftwares[$i]</td>";
  print "
        <center>
    			<td>
    				<form action=\"InstallerSoft.pl?param=".$installedsoftwares[$i]."\"	enctype=\"multipart/form-data\" 
              method=\"post\" value=\"install".$installedsoftwares[$i]."\">
      				<div>
        				<input type=\"submit\" value=\"Déployer\">
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

