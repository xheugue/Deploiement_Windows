#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;
 
#Corps de la page
my @list= (3,'chaine',"bonjour");
my @installedsoftwares=WebService::getComputerSoftwares();
#my @deployedsoftwares=WebService::getDeployedSoftwares();

print "
<html>
<body>";
#print"$t";
print"
 <table border=\"1\">";


print"
 <table border=\"1\">
<tr><th>Liste des programme installés</th><th>Action</th></tr>
";
for(my $i = 0 ; $i < @installedsoftwares ; $i++){
print "<tr><td align=\"center\">$installedsoftwares[$i]</td>";

print "         <center>
			<td>
				<form action=\"Install.pl?btn=".$installedsoftwares[$i]."\" enctype=\"multipart/form-data\" method=\"post\" value=\"install".$installedsoftwares[$i]."\">
				<div>
				<input type=\"submit\" value=\"Déployer\">
				</div>
				</form>
			</center>
		</td>
		";
}
print "</tr></table>";

print"
</body>
</html>
";

