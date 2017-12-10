#!C:\Perl64\bin\perl.exe

use DBI;
use CGI;
use IO::Socket::INET;

#Connection à la base de données
my $dbh = DBI->connect(
"dbi:SQLite:dbname=parcinfo.db",
"",
"",
{ RaiseError => 1}
) or die $DBI::errstr;

$dbh->do("CREATE TABLE IF NOT EXISTS packageNormal(idpackage INTEGER PRIMARY KEY AUTOINCREMENT,nompackage VARCHAR (255), destination VARCHAR (255))");
$dbh->do("CREATE TABLE IF NOT EXISTS packageMsi(idpackage INTEGER PRIMARY KEY AUTOINCREMENT,nompackage VARCHAR (255), destination VARCHAR (255))");
$dbh->do("CREATE TABLE IF NOT EXISTS packageZip(idpackage INTEGER PRIMARY KEY AUTOINCREMENT,nompackage VARCHAR (255), destination VARCHAR (255))");

my $cgi = new CGI;
my $file = $cgi->param('FicherCharge');
#my $destination = $cgi->param('userDestination');
print $file;
if (defined $cgi->param("FicherCharge") ) {
    $query = "INSERT INTO packageNormal (nompackage,destination) VALUES (?,?) ";
	$statement = $dbh->prepare($query);
	$statement->execute($file,true);
}
$dbh->disconnect();


print "Content-Type: text/html\n\n";

#Corps de la page
print "
# <html>
<head>
<meta http-equiv=\"refresh\" content=\"0; URL='../framePack2.html'\" />
</head>
<body>
</body>
</html>
";
