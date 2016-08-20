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

my $flag = "/home/videouser/VIDEO_SERVER/TMP/" . $opt_c . ".processing";

	### If processing is already set, leave until its time
	if(-e "$flag"){
	
	 	print "*** Archive Is Already Running *** \n";
	
	}else{
	
		### About To Begin, Drop our processing flag
		open (MYFILE, ">> $flag");
		print MYFILE "Processing\n";
		close (MYFILE);	
		
		### Test the s3 Server Mounts
                # `nohup ./mounts3.pl >/dev/null 2>&1 &`;

		my @file = `/bin/su - root -c\"ls | find $ftp$feed*.mp4 -type f -mmin +7 2>/dev/null"`;

			foreach(@file){
					
                ### Test the s3 Server Mounts
                `nohup ./home/videouser/VIDEO_SERVER/SCRIPTS/mounts3.pl >/dev/null 2>&1 &`;
                my $clipDestination = '';
                ### Get FileName contents
                my $FilePath = $_;
                $FilePath =~ s/\r|\n//g;
                @GetSegment = split($ftp, $FilePath);
                my $FileName = @GetSegment[1];
                my $ImgName = $FileName;
                $ImgName =~ s/mp4/jpg/;

                ### Get Date and Time Detail From File
                @GetDest = split('_', @GetSegment[1]);
                my $DirStream = @GetDest[0];
                my $DirDate = @GetDest[1];
                my $DirTime = @GetDest[2];

                ### Break Down Date and Time Detail
                my $DirYear = substr($DirDate, 0, 4);
                my $DirMonth = substr($DirDate, 4, 2);
                my $DirDay = substr($DirDate, 6, 2);
                my $DirHour = substr($DirTime, 0, 2);
                my $DirMin = substr($DirTime, 2, 2);
                my $DirSec = substr($DirTime, 4, 2);

                ### Break The Min Dir Seqments
                if($DirMin >= 0 && $DirMin < 5){
                    $DirSegment = '00';
                }elsif($DirMin >= 5 && $DirMin < 10){
                    $DirSegment = '05';
                }elsif($DirMin >= 10 && $DirMin < 15){
                    $DirSegment = '10';
                }elsif($DirMin >= 15 && $DirMin < 20){
                    $DirSegment = '15';
                }elsif($DirMin >= 20 && $DirMin < 25){
                    $DirSegment = '20';
                }elsif($DirMin >= 25 && $DirMin < 30){
                    $DirSegment = '25';
                }elsif($DirMin >= 30 && $DirMin < 35){
                    $DirSegment = '30';
                }elsif($DirMin >= 35 && $DirMin < 40){
                    $DirSegment = '35';
                }elsif($DirMin >= 40 && $DirMin < 45){
                    $DirSegment = '40';
                }elsif($DirMin >= 45 && $DirMin < 50){
                    $DirSegment = '45';
                }elsif($DirMin >= 50 && $DirMin < 55){
                    $DirSegment = '50';
                }elsif($DirMin >=  55){
                    $DirSegment = '55';
                }else{
                    ### TIME FAULT
                    $DirSegment = '99';
                }

                ### Create Our Archive Catalog Locations
                `mkdir -p "$livsmount$client/$project/$DirStream/$DirYear$DirMonth$DirDay/$DirHour/$DirSegment/Thumbs"`;
                `chown apache:apache "$livsmount.$client"."/".$project"."/$DirStream"`;
                `chown apache:apache "$livsmount.$client"."/".$project"."/$DirStream/$DirYear$DirMonth$DirDay"`;
                `chown apache:apache "$livsmount.$client"."/".$project"."/$DirStream/$DirYear$DirMonth$DirDay/$DirHour"`;
                                    `chown apache:apache "$livsmount.$client"."/".$project"."/$DirStream/$DirYear$DirMonth$DirDay/$DirHour/$DirSegment"`;
                `chown apache:apache "$livsmount.$client"."/".$project"."/$DirStream/$DirYear$DirMonth$DirDay/$DirHour/$DirSegment/Thumbs"`;

                ### The RAID Destination Mount
                my $clipDestination = $livsmount . $client . "/" . $project . "/" . $DirStream . "/" . $DirYear . $DirMonth . $DirDay . "/" . $DirHour . "/" . $DirSegment . "/" . $FileName;
                my $imgDestination = $livsmount . $client . "/". $project . "/" . $DirStream . "/" . $DirYear . $DirMonth . $DirDay . "/" . $DirHour . "/" . $DirSegment . "/Thumbs/" . $ImgName;
                my $Destination = $livsmount . $client . "/" . $project . "/" . $DirStream . "/" . $DirYear . $DirMonth . $DirDay . "/" . $DirHour . "/" . $DirSegment . "/";

                my $Mount = $livsmount . $client . "/" . $project;
                my $UTCTime = $DirYear . $DirMonth . $DirDay . $DirHour . $DirSegment;
                my $UTCImg =  $feed . "_" . $DirYear . $DirMonth . $DirDay . "_" . $DirHour . $DirSegment . "00.jpg";

                print "\n" . $FileName . " -> (start) \n\n";

                ### Generate Thumbnail Img
                `/bin/su - root -c \"ffmpeg -i "$FilePath" -f mjpeg -t 0.001 -y "$imgDestination"\"`;
                ### print " Thumbnail Created -> ";
                sleep 1;

                ### Prepare Clip For Puesdo-Streaming
                `cd /usr/local/bin/; ./MP4Box -hint "$FilePath"`;
                ### print " File Hinted -> ";
                sleep 1;

                ### Move To Location
                `mv "$FilePath" "$clipDestination"`;
                print "\n Stored (done) $clipDestination\n";

                ### Change Permissions and Owner
                `chmod 644 "$clipDestination"`;
                `chown apache:apache "$clipDestination"`;
                                    `chmod 644 "$imgDestination"`;
                                    `chown apache:apache "$imgDestination"`;

                ### Check For Completed Segments
                my @Segments = <$Destination/*>;
                my $totalSegments = scalar (@Segments);
                ### my $totalSegments = $#Segments;

                print "$totalSegments\n\n";

                    ### 30 Files + Thumbs Folder / 19 - 3min
                    if($totalSegments == 19){

                    print "\n\nMARK THIS \n\n";
                    $apidump = `lynx --dump "http://127.0.0.1/"$unity"/LIVS_Web/request.php?matrix&mark&stream="$feed"&name="$cam"&file="$UTCImg"&mnt="$Mount"&return=TMVideo&status=completed&utc="$UTCTime`;
                    print $apidump;

                }

			}
		
		### Clean up the process flag
		`rm -rf /home/videouser/VIDEO_SERVER/TMP/$opt_c.processing`;

	}

### No Config File
}else{

    print "*** Invalid Config Specified ***\n*** Use -c CONFIG_FILE_NAME.inc ***\n";

}
exit;
