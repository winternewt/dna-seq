use strict;
use warnings;

use DBI qw(:sql_types);

my $host = "useastdb.ensembl.org";
my $port = "3306";
my $user = "anonymous";
my $pass = "";
my $err_pattern = 'Cannot %s to the Ensembl MySQL server at %s:%d; check your settings & DBI error message: %s';

print "CONNECT\n";
my $dbh = DBI->connect( "DBI:mysql:host=$host;port=$port", $user, $pass ) or
throw(sprintf($err_pattern, 'connect', $host, $port, $DBI::errstr));
print "PING\n";
$dbh->ping() or throw(sprintf($err_pattern, 'ping', $host, $port, $DBI::errstr));
