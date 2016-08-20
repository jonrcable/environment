#!/usr/bin/perl
use Getopt::Std;
use POSIX;
use Time::Local;

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
our $buffer = 0;
our $stream = $feed;
our $pause_offset = 0;
our $sample_offset = 50;

### Clean up any old sorting
runArchiveSort($opt_c);

### Start our never ending loop and nvr eq 0.. ie once started this process must be killed from cmd line
while($streamStart == 1)
{

require "/home/videouser/VIDEO_SERVER/INCLUDE/OFFSET.inc";
our $pause_offset = $stream_offset;
our $sample_offset = $log_offset;
our $time_offset = $buffer_offset;

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
	$buffer_pause = ($buffer/10)+$pause_offset-($time_offset/10);
	# $buffer_pause = ($buffer/10)+$pause_offset;
	if($buffer_pause < 7){
	$buffer_pause = 6;
	}elsif($buffer_pause > 9){
	$buffer_pause = 9;
	}
	## new - ls -1tr | find /home/livs/01"_"* 2>/dev/null | tail -2 | head -1;
	## old - ls -1tr | find $ftp$feed"_"* 2>/dev/null | tail -1
        my $latest_file = `/bin/su - root -c\"ls -1tr | find $ftp$feed"_"* 2>/dev/null | tail -1 | head -1\"`;
        
	### Eliminate any and all spacing and extra chars
        chomp ($file);
        chomp ($latest_file);
	### Sleep enough time to make zen
	print "\nDelay (".$buffer_pause.")\n"; sleep $buffer_pause;

if ($latest_file eq '') {

print "\n No Media Found -> Default Clip \n";
`echo -e '*PLAY-LIST*\n"/usr/local/movies/default2.mp4",5' >> /var/streaming/playlists/$playlist/$playlist.insertlist`;

}else{

	### If the last loop eq the same filename as this loop skip/pause/rerun
		# if($file != ''){
		# @test_buffer_skip = split(/_/, $file);
                # $this_skip_date = @test_buffer_skip[1];
                # $get_skip_time = @test_buffer_skip[2];		 
		# $buffer_skip = process_buffer_skip($this_skip_date, $get_skip_time, $buffer);
		# }

		$file = $latest_file;
		@get_date_parts = split(/_/, $file);
		$this_date = @get_date_parts[1];
		$get_time = @get_date_parts[2];
		
		$offset = process_buffer($this_date, $this_time, $buffer);
		
		# if($buffer_skip eq $offset){
		# }else{
		#	print "\n Insert Darwin Playlist - Skipped Buffer Segment (".$stream.") -> ";
		#	sendToDarwin($buffer_skip, $stream);
		# }

		print "\nNo new file found - BufferSet(".$buffer.")\n";
        	
                if($offset != 'error'){
                        $item = $ftp.$feed."_".$offset;
                        ### Wait till the file is unlocked
                        $count = 0;
                        `lsof -w $item`;
                        while($? == 0){
                                last if $count == 2;
                                $count++;
                                sleep 1;
                                `lsof -w $item`;
                                print $count . " - ";
                        }
                        if($count < 2){

                                `chmod 0755 $item`;

                        }

                }else{
			print "\n Buffer Error -> Default Clip \n";
			`echo -e '*PLAY-LIST*\n"/usr/local/movies/default2.mp4",5' >> /var/streaming/playlists/$playlist/$playlist.insertlist`;
		}
		$file = $item;
		
		$get_buffer = get_buffer_length();
        	if($get_buffer > $buffer){
                	our $buffer = $get_buffer + $time_offset;
                                print "\n Increase Playlist Buffer - Using (".$buffer.") -> ";
				`echo -e '*PLAY-LIST*\n"/usr/local/movies/default2.mp4",5' >> /var/streaming/playlists/$playlist/$playlist.insertlist`;			
		}else{
 
                        print "\nNewBufferSet(".$get_buffer.")\n";

                                print "\n Insert Darwin Playlist - Using Buffer (".$stream.") -> ";

                                ### Send To LIVS Stream via Darwin Sub-Routin
                                if( $last_offset eq $offset ){
					# Send Buffering Clip
					our $buffer = $buffer - 10;
					$offset = process_buffer($this_date, $this_time, $buffer);
					print "Buffer Clip -> ";
					
				}else{
				$offset = process_buffer($this_date, $this_time, $buffer);
				$last_offset = $offset;
				
				}
				sleep 1;
				sendToDarwin($offset, $stream);
		
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

sub process_buffer_skip($this_skip_date, $get_skip_time){
        require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";
        @clean_time = split(/.mp4/,$get_skip_time);
        $this_time = @clean_time[0];
        $this_year = substr($this_skip_date, 0, 4);
        $this_month = substr($this_skip_date, 4, 2)-1;
        $this_day = substr($this_skip_date, 6, 2);
        $this_hour = substr($this_time, 0, 2);
        $this_min = substr($this_time, 2, 2);
        $this_sec = substr($this_time, 4, 2);
        $this_clip = timelocal($this_sec+10, $this_min, $this_hour, $this_day, $this_month, $this_year);
        $this_buffer = $this_clip - $buffer;
        $new_clip = strftime( "%Y%m%d_%H%M%S", localtime($this_buffer) );
        my $buffer_clip = $ftp.$feed."_".$new_clip.".mp4";
        if (-e $buffer_clip) {
                # print "\n".$this_date."_".$this_time." buffered-> ".$buffer_clip."\n";
                print "\n";
                return $new_clip.".mp4";
        }else{
                print "\nERROR: Buffer - No File Found ".$buffer_clip."\n";
                return 'error';
        }

}

sub process_buffer($this_date, $get_time){
	require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";
        @clean_time = split(/.mp4/,$get_time);
        $this_time = @clean_time[0];
        $this_year = substr($this_date, 0, 4);
        $this_month = substr($this_date, 4, 2)-1;
        $this_day = substr($this_date, 6, 2);
        $this_hour = substr($this_time, 0, 2);
        $this_min = substr($this_time, 2, 2);
        $this_sec = substr($this_time, 4, 2);
        $this_clip = timelocal($this_sec, $this_min, $this_hour, $this_day, $this_month, $this_year);
        $this_buffer = $this_clip - $buffer;
        $new_clip = strftime( "%Y%m%d_%H%M%S", localtime($this_buffer) );
        my $buffer_clip = $ftp.$feed."_".$new_clip.".mp4";
        if (-e $buffer_clip) {
                # print "\n".$this_date."_".$this_time." buffered-> ".$buffer_clip."\n";
		print "\n";
		return $new_clip.".mp4";
        }else{
                print "\nERROR: Buffer - No File Found ".$buffer_clip."\n";
		return 'error';
        }

}

### Test the average network speed
sub get_buffer_length(){
my $avg_upload = `/bin/su - root -c\"tail -$sample_offset /var/log/vsftpd.log | grep "OK UPLOAD"\"`;
@last_ten = split(/\n/, $avg_upload);
$total_size=0;
$total_avg=0;
$total_items=0;
foreach $item(@last_ten){
        @get_avg = split(/,/, $item);
        $item_size = @get_avg[2];
        $item_avg = @get_avg[3];
        $item_size =~ s/ bytes//g;
        $item_avg =~ s/Kbyte\/sec//g;
        $total_size = $total_size + $item_size;
        $total_avg = $total_avg + $item_avg;
        $total_items = $total_items + 1;

        # print "Item ".$total_items."\n";
        # print "Item - Size: ".$item_size." bytes (".$item_avg."Kbyte\/sec)\n";
        # print "Total- Size: ".$total_size." bytes (".$total_avg."Kbyte\/sec)\n\n";
}
$avg_ksize = ($total_size/128)/$total_items;
$avg_ksec = $total_avg/$total_items;
$result = $avg_ksize/$avg_ksec;
$buffer_length = round_buffer_length($result);
# print $avg_upload;
print "\n\nNetwork Stats: (avg)".$avg_ksec. "(size)".$avg_ksize. "(buffer)".$buffer_length."(global)".$buffer;
return $buffer_length;
}
sub round_buffer_length($) {

        my $n = int shift;

        if(($n % 10) == 0) {
                $n = 10;
                return($n);
        } else {
                my $sign = 1;
                if($n < 0) { $sign = 0; }

                $n = int ($n / 10);
                $n *= 10;
                if($sign) {
                        $n += 10;
                }
                return($n);
        }
        return(-1);
}

### SEND TO DARWIN PLAYLIST ###
sub sendToDarwin($offset, $stream){
	require "/home/videouser/VIDEO_SERVER/CONFIGS/$opt_c";

	$file = $ftp.$stream."_".$offset;
	 
	if(-d "/usr/local/movies/videoserver_tmp/$playlist"){
        ### FEED TEMP DIR EXISTS
        }else{
        `mkdir /usr/local/movies/videoserver_tmp/$playlist`;
        `chmod 0755 /usr/local/movies/videoserver_tmp/$playlist`;
        `chown qtss:qtss /usr/local/movies/videoserver_tmp/$playlist`;
        }

        # my $file=shift;

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

	if(-e "/usr/local/movies/videoserver_tmp/$playlist/@name[1]"){
		print $file;
	}
		
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
