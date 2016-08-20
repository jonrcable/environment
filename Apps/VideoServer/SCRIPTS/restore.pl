#!/usr/bin/perl
use Getopt::Std;
use POSIX;

require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

### Check The Available Of The s3 Mounts
print "* Starting Server Restore -> ";

### Dump The mySQL Table
print "\nChecking mySQL Server -> ";

$mySQLService = `service mysqld status`;

if($mySQLService == 'mysqld is stopped'){
	print "mySQL is not running... starting -> ";
	`service mysqld start`;
}

print "Extracting Backup Archive -> ";
`nohup tar -xzf /home/videouser/VIDEO_SERVER/BACKUP/unity-backup.tar.gz -C / >/dev/null 2>&1 &`;

print "Restoring mySQL Backup -> ";
`mysql -h localhost -u $username -p$password $database < /home/videouser/VIDEO_SERVER/TMP/unity-core.sql`;

print "DONE\n";
