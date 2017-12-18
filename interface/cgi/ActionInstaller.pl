#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use WebService;
 
#Corps de la page

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
<th>Liste des programme installés</th>
";
for(my $i = 0 ; $i < @installedsoftwares ; $i++){
print "<tr><td align=\"center\">$installedsoftwares[$i]</td>";

print " <center>
			<td>
				<form >
				<div>
				<input type=\"submit\" value=\"Deployer\">
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

