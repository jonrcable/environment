#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Std;
use POSIX;

### Define our client include file
$opt_s = "0";
getopt('s:');
chomp($opt_s);

require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

if($opt_s eq 'start'){

	### Check Unity Video
	$testMount = $livsmount;
	$s3bucket = 'unity-client-video';
	checkEndpoint($testMount, $s3bucket);

	### Check Unity Documents
	$testMount = $docsmount;
	$s3bucket = 'unity-client-documents';
	checkEndpoint($testMount, $s3bucket);

	### Global Checks
	checkPaths();
	bindEndpoint();

}elsif($opt_s eq 'stop'){

	stopMounts();	

}elsif($opt_s eq 'service'){

    ### Check Unity Video
    $testMount = $livsmount;
    $s3bucket = 'unity-client-video';
    checkEndpoint($testMount, $s3bucket);

}else{

    ### Global Checks
    ### Check Unity Video
    $testMount = $livsmount;
    $s3bucket = 'unity-client-video';
    checkEndpoint($testMount, $s3bucket);

    ### Check Unity Documents
    $testMount = $docsmount;
    $s3bucket = 'unity-client-documents';
    checkEndpoint($testMount, $s3bucket);

    ### Global Checks
    checkPaths();
    bindEndpoint();
        
}

### Sub Routines
sub checkEndpoint($testMount, $s3bucket){

    print "* Mount Test - $testMount >> $s3bucket -> ";
    `/bin/df | /bin/grep $testMount`;
    if($? != 0){

        if(-d "$testMount"){
            ## No need to create a directory
                    print "Mount Point Exists -> CHECK";
            `umount $testMount > /dev/null 2>&1`;
            `s3fs $s3bucket $testMount -o allow_other -o -use_cache=/tmp -o -connect_timeout=30 -o -retries=6`;
            checks3($testMount);
        }else{
            ## Create The Path
            print "Creating Mount Point -> CHECK";
            `mkdir $testMount`;
            `s3fs $s3bucket $testMount -o allow_other -o -use_cache=/tmp -o -connect_timeout=30 -o -retries=6`;
            checks3($testMount);
        }

    }else{

        checks3($testMount);

    }
    # print "DONE \n";

}

sub checks3($testMount){

    require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

    print "\n* Client Test - $testMount -> ";
    if(-d "$testMount/$client"){
        print "Client Exists -> ";
    }else{
        ## Make client directory
        print "Client Created -> ";
        `mkdir $testMount/$client`;
    }

    if(-d "$testMount/$client/$project"){
        print "Project Exists -> ";
    }else{
        ## Make project directory
        print "Project Created -> ";
        `mkdir $testMount/$client/$project`;
    }
	print " DONE \n";

}

sub checkPaths(){

    require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

	print "* Path Test - "; 
    if(-d "$docsmount/$client/$project/Files"){
        print "* Documents Path Exists -> ";
    }else{
        ## Make project directory
        print "* Documents Path Created -> ";
        `mkdir $docsmount/$client/$project/Files`;
    }

    if(-d "$docsmount/$client/$project/Proxy"){
        print "Proxy Path Exists -> ";
    }else{
        ## Make project directory
        print "Proxy Path Created -> ";
        `mkdir $docsmount/$client/$project/Proxy`;
    }

    if(-d "/var/www/html/$unity/DOC_Web/Files"){
        print "Files Dest Exists -> ";
    }else{
        ## Make project directory
        print "Files Dest Created -> ";
        `mkdir /var/www/html/$unity/DOC_Web/Files`;
    }

    if(-d "/var/www/html/$unity/DOC_Web/Proxy"){
        print "Proxy Dest Exists -> ";
    }else{
        ## Make project directory
        print "Proxy Dest Created -> ";
        `mkdir /var/www/html/$unity/DOC_Web/Proxy`;
    }

    if(-d "/var/www/html/$unity/LIVS_Web/Files"){
        print "LIVS Dest Exists -> ";
    }else{
        ## Make project directory
        print "LIVS Dest Created -> ";
        `mkdir /var/www/html/$unity/LIVS_Web/Files`;
    }

	print " DONE \n";

}

sub bindEndpoint(){

    require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

    # print "Checking binded Mounts...\n";
    `/bin/mount | /bin/grep /var/www/html/$unity/DOC_Web/Files`;
    if($? != 0){

        print "* Bind Docs to Path Created -> ";
        `mount --bind $docsmount$client/$project/Files /var/www/html/$unity/DOC_Web/Files`;

    }else{

        print "* Bind Docs to Path Exists -> ";

    }

    `/bin/mount | /bin/grep /var/www/html/$unity/DOC_Web/Proxy`;
    if($? != 0){

        print "Bind Proxy to Path Created -> ";
        `mount --bind $docsmount$client/$project/Proxy /var/www/html/$unity/DOC_Web/Proxy`;

    }else{

        print "Bind Proxy to Path Exists -> ";

    }

    `/bin/mount | /bin/grep /var/www/html/$unity/LIVS_Web/Files`;
    if($? != 0){

        print "Bind LIVS to Path Created -> ";
        `mount --bind $livsmount$client/$project /var/www/html/$unity/LIVS_Web/Files`;

    }else{

        print "Bind LIVS to Path Exists -> ";

    }
    print "DONE \n";

}

sub stopMounts(){

	require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";
	print "* Breaking Binded Paths -> ";
	`umount $docsmount$client/$project/Proxy`;
	`umount $docsmount$client/$project/Files`;
	`umount $livsmount$client/$project`;
	print "Disconnecting Mounted Devices -> ";
	`umount $docsmount`;
	`umount $livsmount`;
	print "DONE \n";
		
}
