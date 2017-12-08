#!C:\Perl64\bin\perl.exe
use warnings;
use strict;
use DBI;
print "Content-type: text/html; charset=iso-8859-1\n\n";


#Connection à la base de données
  my $dbh = DBI->connect(          
      "dbi:SQLite:dbname=parcinfo.db", 
      "",
      "",
      { RaiseError => 1}
  ) or die $DBI::errstr;

#Création de l'ensemble des tables
  $dbh->do("DROP TABLE IF EXISTS packageNormal");
  $dbh->do("DROP TABLE IF EXISTS packageMsi");
  $dbh->do("DROP TABLE IF EXISTS packageZip");
  $dbh->do("CREATE TABLE packageNormal(idpackage INT PRIMARY KEY,nompackage VARCHAR (255), destination VARCHAR (255))");
  $dbh->do("CREATE TABLE packageMsi(idpackage INT PRIMARY KEY,nompackage VARCHAR (255), destination VARCHAR (255))");
  $dbh->do("CREATE TABLE packageZip(idpackage INT PRIMARY KEY,nompackage VARCHAR (255), destination VARCHAR (255))");
  $dbh->do("INSERT INTO packageNormal VALUES(1,'Package 1','127.0.0.1')");
  $dbh->do("INSERT INTO packageNormal VALUES(2,'Package 2','127.0.0.2')");
  $dbh->do("INSERT INTO packageNormal VALUES(3,'Package 3','127.0.0.3')");
  $dbh->do("INSERT INTO packageMsi VALUES(4,'Package 4','127.0.0.3')");
  $dbh->do("INSERT INTO packageMsi VALUES(5,'Package 5','127.0.0.4')");
  $dbh->do("INSERT INTO packageMsi VALUES(6,'Package 6','127.0.0.5')");
  $dbh->do("INSERT INTO packageZip VALUES(7,'Package 7','127.0.0.6')");
  $dbh->do("INSERT INTO packageZip VALUES(8,'Package 8','127.0.0.7')");

#Récupération des données
  my $sth = $dbh->prepare( "SELECT * FROM packageMsi" );  
  $sth->execute();
      
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
$sth->finish();
$dbh->disconnect();

