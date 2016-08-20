#!/usr/bin/perl
use Getopt::Std;
use POSIX;

### We have to get/require a config file to continue
if(-e "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc"){
require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

my $flag = "/home/videouser/VIDEO_SERVER/TMP/file.processing";

        ### If processing is already set, leave until its time
        if(-e "$flag"){

                print "*** Archive Is Already Running *** \n";
		exit;

        }else{

                ### About To Begin, Drop our processing flag
                open (MYFILE, ">> $flag");
                print MYFILE "Processing\n";
                close (MYFILE);
		my $round = `lynx --dump "http://127.0.0.1/"$unity"/LIVS_Web/request.php?proxy&total"`;
		my $total = trim($round);
		while($total > 0){
			process();
			$total = $total -1;
		}
		### Clean up the process flag
                `rm -rf /home/videouser/VIDEO_SERVER/TMP/file.processing`;
		exit;

	}
}

### All Functions

### Main Media Process Function
sub process{

### We have to get/require a config file to continue
if(-e "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc"){
require "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc";

### Check for new files to proces from the api
my $file = `lynx --dump "http://127.0.0.1/"$unity"/LIVS_Web/request.php?proxy&next"`;
my $check = trim($file);

### Check to see if there is a new file
if($check != "DONE"){

### Process the file to determine it attributes
my @value = split(":", $file);
$ID = trim(@value[0]);
$Path = trim(@value[1]);
my @type = split("\\.", $Path);
$Dst = @type[0];
$Ext = @type[1];
my @Dir = split("file_", $Path);
$DstDir = @Dir[0];

### Set the source and destination paths
$serverPath = $docsmount.$client."/".$project;
$filePath = $serverPath."/Files/".$Path; 
$ProxyRequest = 0;

### Determine if we can process the file type
if(($Ext=~/pdf/) || ($Ext=~/odt/) || ($Ext=~/doc/) || ($Ext=~/docx/) || ($Ext=~/xls/) || ($Ext=~/xlsx/) || ($Ext=~/ppt/) || ($Ext=~/pptx/)){
print "Convert DOC Type To PDF \n";
$proxyDst = $serverPath."/Proxy/".$DstDir;
print `cd /opt/libreoffice3.5/program/; ./soffice --headless --invisible --convert-to pdf --outdir $proxyDst $filePath`;
$ProxyRequest = 1;

}elsif(($Ext=~/jpg/) || ($Ext=~/png/)){
print "Convert IMG Type To Thumb \n";
$proxyDst = $serverPath."/Proxy/".$Dst.".jpg";
print `convert -format jpg -geometry 100 $filePath $proxyDst`; 
$ProxyRequest = 1;

}elsif(($Ext=~/mp4/) || ($Ext=~/mov/) || ($Ext=~/avi/)){
print "Convery VID Type To Thumb \n";
$proxyDst = $serverPath."/Proxy/".$Dst.".jpg";
print `cd /usr/local/bin/; ./ffmpeg -y -itsoffset -6 -i $filePath -vcodec mjpeg -vframes 1 -an -f rawvideo -s 320x240 $proxyDst`;
$ProxyRequest = 1;

}else{
## Unknown File Type
$ProxyRequest = 2;

}

if($ProxyRequest==1){
### Mark Success
my $mark = `lynx --dump "http://127.0.0.1/"$unity"/LIVS_Web/request.php?proxy&mark&ID="$ID"&result=OK"`;
my $done = trim($mark);

}elsif($ProxyRequest==2){
### Mark Failure
my $mark = `lynx --dump "http://127.0.0.1/"$unity"/LIVS_Web/request.php?proxy&mark&ID="$ID"&result=FAIL"`;
my $done = trim($mark);

}

### File Proxy Status
print "File ".$ID.": ".$done; 

}else{

### We are done. Exit and cleanup
exit;

}

### End Config require
}

### End Process Function
}

### Common Trim Function For Lynx
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
