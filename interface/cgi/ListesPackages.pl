#!C:\Perl64\bin\perl.exe

use DBI;
use CGI;

#Connection à la base de données et la cree si elle n'existe pas
  my $dbh = DBI->connect(
      "dbi:SQLite:dbname=parcinfo.db",
      "",
      "",
      { RaiseError => 1}
  ) or die $DBI::errstr;

my $sth=$dbh->prepare("select * from packageNormal");
$sth->execute();

#Envoi du header
print "Content-Type: text/html\n\n";


#Affichage des données
  print "
      <html>
          <style>
              table, th, td {
                  border: 2px solid black;
                  border-collapse: collapse;
              }
              th, td {
                  padding: 5px;
              }
          </style>
          <body>
              <table style=\"width:100%\">
                    <tr>
                      <th>IdPackage</th>
                      <th>NomPackage</th>
                      <th>Adresse Destination</th>
                    </tr>";
                    while (my @row=$sth->fetchrow_array){
                  	print
                  	"<tr>
                  		<td>".$row[0]."</td>
                  		<td>".$row[1]."</td>
                  		<td>".$row[2]." </td>";
                  	print "</tr>";
                  	}
              print "</table>
          </body>
      </html>
  ";
$dbh->disconnect();
