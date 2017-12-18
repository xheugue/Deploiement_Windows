#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;


my @deplyedsoftwares=WebService::getDeployedSoftwares();
#Corps de la page
print "
<html>
<body>";
#print"$t";
print"
 <table border=\"1\">";
print"
<table border=\"1\">
  <th>Liste des programmes déployés</th>";
  for(my $i = 0 ; $i < @deplyedsoftwares ; $i++){
  print "<tr><td align=\"center\">$deplyedsoftwares[$i]</td>";
  print "
        <center>
    			<td>
    				<form action=\"DesinstallerSoft.pl?param=".$deplyedsoftwares[$i]."\"	enctype=\"multipart/form-data\" 
              method=\"post\" value=\"install".$deplyedsoftwares[$i]."\">
      				<div>
        				<input type=\"submit\" value=\"Désinstaller\">
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

