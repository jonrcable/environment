#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Std;
use POSIX;

### Define our client include file
$opt_c = "0";
getopt('c:');
chomp($opt_c);

### We have to get/require a config file to continue
if(-e "/home/videouser/VIDEO_SERVER/CONFIGS/$opt_c"){

require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";
require "/home/videouser/VIDEO_SERVER/CONFIGS/$opt_c";

### Define these things ahead of time
my $streamStart = 1;
my $file = 0;

### Clean up any old sorting
runArchiveSort($opt_c);

### Start our never ending loop and nvr eq 0.. ie once started this process must be killed from cmd line
while($streamStart == 1)
{

    ### List the most recent file from the streaming directory

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

    my $latest_file = `/bin/su - root -c\"ls -1tr | find $ftp$feed"_"* 2>/dev/null | tail -1\"`;

    ### Eliminate any and all spacing and extra chars
    chomp ($file);
    chomp ($latest_file);

    print $file . " = " . $latest_file;

    ### If the last loop eq the same filename as this loop skip/pause/rerun
    if( $file eq $latest_file ){

        print " No new file found \n";
        sleep 1;

    }else{

        ### Else we have a new clip to broadcast
        ### Set our flag to the most recent find then change ownership
        $file = $latest_file;

        print "\n";
        print `date`;

        ### Wait till the file is unlocked
        $count = 0;
        `lsof -w $file`;

        while($? == 0){

            last if $count == 9;
            $count++;
            sleep 1;
            `lsof -w $file`;
            print $count . " - ";

        }
        if($count < 9){

            `chmod 0755 $file`;

            print " Insert Darwin Playlist -> ";

            ### Send To LIVS Stream via Darwin Sub-Routin
            sendToDarwin($file, $ftp);
            print $file;

        }

    }

    ### At the end of each loop look to clean up a few files
    cleanUpPlaylist();
		
	if($min == 05 || $min == 10 || $min == 15 || $min == 20 || $min == 25 || $min == 30 || $min == 35 || $min == 40 || $min == 45 || $min == 50 || $min == 55){

		### Kick The Sorting Of LIVS
		runArchiveSort($opt_c);
		runProxy();

	}

	### Run our Maint Script
	if($hr == 23 && $min == 55){

		runMaint();

	}elsif($hr == 23 && $min == 59){

		cleanMaint();

	}

}

}else{

    print "*** Invalid Config Specified ***\n*** Use -c CONFIG_FILE_NAME.inc ***\n";

}

########################################
######## VIDEO SERVER FUNCTIONS ########
########################################

### SEND TO DARWIN PLAYLIST ###
sub sendToDarwin($file, $ftp){

    if(-d "/usr/local/movies/videoserver_tmp/$playlist"){
    ### FEED TEMP DIR EXISTS
    }else{
    `mkdir /usr/local/movies/videoserver_tmp/$playlist`;
    `chmod 0755 /usr/local/movies/videoserver_tmp/$playlist`;
    `chown qtss:qtss /usr/local/movies/videoserver_tmp/$playlist`;
    }

    my $file=shift;

    ### Get the file name
    @name = split(/$ftp/, $file);

    ### Copy to the broadcast tmp directroy
    `cp $file "/usr/local/movies/videoserver_tmp/$playlist"`;

    ### Safe exit on file error
    $count = 0;
    while(1){
        last if $count == 9;
        $count++;
        last if -e "/usr/local/movies/videoserver_tmp/$playlist/@name[1]";
    }

    ### Prepare file for streaming
    `/bin/su - root -c\"MP4Box -hint "/usr/local/movies/videoserver_tmp/$playlist/@name[1]"\"`;
    `chown qtss:qtss "/usr/local/movies/videoserver_tmp/$playlist/@name[1]"`;

    ### Finally add to the Playlist que
    `echo -e '*PLAY-LIST*\n"/usr/local/movies/videoserver_tmp/$playlist/@name[1]",5' >> /var/streaming/playlists/$playlist/$playlist.insertlist`;
		
}

### CLEANUP THE DARWIN TMP FOLDERS ###
sub cleanUpPlaylist{

    ### Do some routine cleanup on the tmp directory
    `find /usr/local/movies/videoserver_tmp/$playlist/*.mp4 -type f -mmin +30 -delete 2>/dev/null`;

}

### RUN ARCHIVE SORT/CLEAN LIVS DIR ###
sub runArchiveSort($opt_c){

	### If processing is already set, leave until its time
	if(-e "/home/videouser/VIDEO_SERVER/TMP/$opt_c.processing"){
	
		### print "*** Archive Is Already Running *** \n";
	
	}else{
	
		### Kick The Archive
		### print "\n\n *** Kicking Archive *** \n";
		`nohup ./ondemand.pl -c $opt_c >/dev/null 2>&1 &`;

	}

}

### RUN FILE PROXY SERVICE ###
sub runProxy(){

    ### Kick The Archive
    ### print "\n\n *** Kicking Archive *** \n";
    `nohup ./proxyservice.pl >/dev/null 2>&1 &`;

}

### RUN BACKUP N MAINT ###
sub runMaint(){

    ### If processing is already set, leave until its time
    if(-e "/home/videouser/VIDEO_SERVER/TMP/backup.running"){

            ### print "*** Backup Is Already Running *** \n";

    }else{

            ### Kick The Backup
            ### print "\n\n *** Kicking Archive *** \n";
            `nohup ./backupsql.pl >/dev/null 2>&1 &`;

    }

}

### CLEAN MAINT SCRIPT
sub cleanMaint(){

    ### Remove the trigger file
    `rm -rf /home/videouser/VIDEO_SERVER/TMP/backup.running`;

}				
