#!/usr/bin/perl
use Getopt::Std;
use POSIX;

my $flag = "/home/videouser/VIDEO_SERVER/TMP/backup.running";
require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

### About To Begin, Drop our processing flag
open (MYFILE, ">> $flag");
print MYFILE "Processing\n";
close (MYFILE);

### Check The Available Of The s3 Mounts
print "* Starting Server Backup -> ";

$testMount = '/mnt/unity-sql';
$s3bucket = 'unity-client-sql';

### Check The Available Of The s3 Mounts
checkEndpoint($testMount, $s3bucket);

### Dump The mySQL Table
print "\nChecking mySQL Server -> ";

$mySQLService = `service mysqld status`;

if($mySQLService == 'mysqld is stopped'){
	print "mySQL is not running... starting -> ";
	`service mysqld start`;
}

print "Making mySQL Backup -> ";
`mysqldump --add-drop-table -h localhost -u $username -p$password $database > /home/videouser/VIDEO_SERVER/TMP/unity-core.sql`;

print "Compiling Backup Archive -> ";
`tar -czPf /home/videouser/VIDEO_SERVER/BACKUP/unity-backup.tar.gz /home/videouser/VIDEO_SERVER/TMP/unity-core.sql /home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc /home/videouser/VIDEO_SERVER/CONFIGS/STREAM* /var/www/html/$unity/includes/config.php /var/www/html/$unity/unity_core/Config.php /var/www/html/$unity/unity_core/Unity_Config.xml /var/www/html/$unity/template/images/logo.jpg`;

### Move The DB to the s3 Mounts
print "Moving to Client Mount -> ";

### Determine When/Where we need to go with this

($sec, $min, $hr, $day, $month, $year, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();

        $year = 1900 + $year;
        $month = sprintf("%2d", $month+1);
        $month =~ tr/ /0/;
        $day = sprintf("%2d", $day);
        $day =~ tr/ /0/;
        $hr = sprintf("%2d", $hr);
        $hr =~ tr/ /0/;
        $min = sprintf("%2d", $min);
        $min =~ tr/ /0/;

`cp /home/videouser/VIDEO_SERVER/BACKUP/unity-backup.tar.gz $testMount/$client/$project/unity"-"DB"-"$year$month$day"_"$hr$min.tar.gz`;

### Clean the tmp folders
print " Cleaning TMP Folders -> ";
`tmpwatch -maf $tmplife /tmp`;

### Prune the sql backups
print " Pruning Old Backups -> ";
`tmpwatch -maf $sqllife /mnt/unity-sql/$client/$project/`;

### Unmount the SQL Volume
print " Unmount the Backup Volume -> ";
`umount $testMount`;

print " DONE \n";

### Additional Functions

sub checkEndpoint($testMount, $s3bucket){

# print "Testing $testMount >> $s3bucket -> ";
`/bin/df | /bin/grep $testMount`;
if($? != 0){

	if(-d "$testMount"){
		## No need to create a directory
                print "Creating Mount -> ";
		# `umount $testMount`;
		`s3fs $s3bucket $testMount -o allow_other -o -use_cache=/tmp -o -connect_timeout=30 -o -retries=6`;
		checks3($testMount);
	}else{
		## Create The Path
		print "Creating Backup Path -> Creating Mount -> ";
		`mkdir $testMount`;
		`s3fs $s3bucket $testMount -o allow_other -o -use_cache=/tmp -o -connect_timeout=30 -o -retries=6`;
		checks3($testMount);
	}

}else{

	checks3($testMount);

}

}

sub checks3($testMount){

require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

        # print "Testing The Directories... $testMount\n";
	if(-d "$testMount/$client"){
                print "Client Exists -> ";
        }else{
                ## Make client directory
		print "Client Created ->  ";
		`mkdir $testMount/$client`;
        }

        if(-d "$testMount/$client/$project"){
                print "Project Exists -> ";
        }else{
          	## Make project directory
		print "Project Created -> ";
                `mkdir $testMount/$client/$project`;
        }

}
# print "DONE\n";
