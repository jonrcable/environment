#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Std;
use POSIX;

print "\n\nWelcome to the Automated Unity Installer \n\n";

if(-e "/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc"){

	print "This server appears to have an existing configuration.\n";
	$promptBackup = &promptUser("Backup Existing Configuration and Database? \n", "yes");
	if($promptBackup eq yes){
	`/usr/bin/perl /home/videouser/VIDEO_SERVER/SCRIPTS/backupsql.pl`;
	print "Backup Completed.\n";
	}	

}else{

	print "This server does NOT have a existing configuration.\n";

}

$promptStart = &promptUser("Continue With Setup? \n(Doing so may wipe existing configuration)", "yes");

if($promptStart eq yes){
	print "* Starting The Automated System Installer -> \n";
	
	print "\n* Starting Step 1: Enter The New Server Details \n";
	$promptFQDN = &promptUser("Set the Server FQDN/URL? \n", "http://ec2-107-20-67-17.compute-1.amazonaws.com/");
	$promptIP = &promptUser("Set the Server IP Address? \n", "107.20.67.17");
	
	print "\n* Starting Step 2: Enter The New Unity Details \n";
	$promptUnity = &promptUser("Set the Unity directory? \n", "unity");
	$promptDBHost = &promptUser("Set the Unity database server? \n", "localhost");
        $promptDBName  = &promptUser("Set the Unity database name? \n", "unity-core");
	$promptDBUser = &promptUser("Set the Unity database username? \n", "unity-sql");
	$promptDBPass = &promptUser("Set the Unity database password? \n", "(REQUIRED)");
	
	print "\n* Starting Step 3: Enter The New Cleint Details \n";
	$promptClient = &promptUser("Set the client NFS directory? \n", "BIGOIL");
	$promptProject = &promptUser("Set the project NFS directory? \n", "DEMORUN");

	print "\n* Starting Step 4: Enter The FTP Path and Media Mount Details \n";
	$promptFTP = &promptUser("Set the default LIVS FTP Path? \n", "/home/livs/");
	$promptLIVS = &promptUser("Set the default LIVS NFS Mount? \n", "/mnt/unity-video/");
	$promptDOCS = &promptUser("Set the default DOCS NFS Mount? \n", "/mnt/unity-documents/");	

        print "\n* Starting Step 5: Enter The Config Settings \n";
	$promptTmplife = &promptUser("Set the default TMP Cache? \n", "12");        
	$promptSqllife = &promptUser("Set the default SQL Life? \n", "240");

	print "\n* Starting Step 6: Enter Stream Details \n";
	$promptStream1 = &promptUser("Setup StreamID 01? \n", "yes");

	if($promptStream1 eq yes){
		$promptFeed1 = 01;
		$promptSite = &promptUser("Set default Stream Site Name? \n", "EI-123B");
		$promptCam1 = &promptUser("Set StreamID 1 Camera Name? \n", "ROV1");
		$promptPlaylist1 = &promptUser("Set StreamID 1 Playlist Name? \n", "STREAM01");
		$promptRelay1 = &promptUser("Set StreamID 1 Relay URL? \n", "ec2-107-22-0-12.compute-1.amazonaws.com");
		$promptEndpoint1 =  &promptUser("Set StreamID 1 Endpoint Name? \n", "STREAM1.stream");

		$promptStream2 = &promptUser("Setup StreamID 02? \n", "no");

        	if($promptStream2 eq yes){
                	$promptFeed2 = 02;
                	$promptCam2 = &promptUser("Set StreamID 2 Camera Name? \n", "ROV2");
                	$promptPlaylist2 = &promptUser("Set StreamID 2 Playlist Name? \n", "STREAM02");
			$promptRelay2 = &promptUser("Set StreamID 2 Relay URL? \n", "ec2-107-22-0-12.compute-1.amazonaws.com");
                	$promptEndpoint2 =  &promptUser("Set StreamID 2 Endpoint File? \n", "STREAM2.stream");
        
        	}

	}

### Write The Master Config
$promptConfig = &promptUser("Proceed Writing Master Config? \n", "yes/no");

                if($promptConfig eq yes){

			print "* Writing Master Config -> ";
			open (MYFILE, '>/home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc');
 			print MYFILE "##########################################\n";
                        print MYFILE "#### Master - LIVS Config\n";
                        print MYFILE "#### Generated Using The Unity Installer\n";
			print MYFILE "##########################################\n\n";
			print MYFILE "#### FQDN\n";
			print MYFILE "\$fqdn = '$promptFQDN'\;\n";
                        print MYFILE "#### IP Address\n";
                        print MYFILE "\$ip = '$promptIP'\;\n";
                        print MYFILE "#### Unity Location\n";
                        print MYFILE "\$unity = '$promptUnity'\;\n";
                        print MYFILE "#### Unity SQL Host\n";
                        print MYFILE "\$hostname = '$promptDBHost'\;\n";
                        print MYFILE "#### Unity SQL User\n";
                        print MYFILE "\$username = '$promptDBUser'\;\n";
                        print MYFILE "#### Unity SQL Pass\n";
                        print MYFILE "\$password = '$promptDBPass'\;\n";
                        print MYFILE "#### Unity SQL Name\n";
                        print MYFILE "\$database = '$promptDBName'\;\n";			
                        print MYFILE "#### Client Directory\n";
                        print MYFILE "\$client = '$promptClient'\;\n";
                        print MYFILE "#### Project Directory\n";
                        print MYFILE "\$project = '$promptProject'\;\n";
                        print MYFILE "#### Temp Directory Cache Cleanup\n";
                        print MYFILE "\$tmplife = '$promptTmplife'\;\n";
                        print MYFILE "#### SQL Backup Lifespan\n";
                        print MYFILE "\$sqllife = '$promptSqllife'\;\n";
                        print MYFILE "#### Default FTP Location\n";
                        print MYFILE "\$ftp = '$promptFTP'\;\n";
                        print MYFILE "#### Default LIVS Mount\n";
                        print MYFILE "\$livsmount = '$promptLIVS'\;\n";
                        print MYFILE "#### Default DOCS Mount\n";
                        print MYFILE "\$docsmount = '$promptDOCS'\;\n";
			close (MYFILE);
			sleep 1;
			print "Master Config Setup Successfully \n";
			`chmod 400 /home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc`;
			`chown videouser:videouser /home/videouser/VIDEO_SERVER/INCLUDE/MasterConfig.inc`; 		
	
                }

		if($promptStream1 eq yes){
			
			$stream = sprintf("%02d",$promptFeed1);
			$site = $promptSite;
			$cam = $promptCam1;
			$playlist = $promptPlaylist1;
			$relay = $promptRelay1;
			$endpoint = $promptEndpoint1; 
			writeStream($stream, $site, $cam, $playlist, $relay, $endpoint);
		
		}

		if($promptStream2 eq yes){

                        $stream = sprintf("%02d",$promptFeed2);
                        $site = $promptSite;
                        $cam = $promptCam2;
                        $playlist = $promptPlaylist2;
			$relay = $promptRelay2;
			$endpoint = $promptEndpoint2;
			writeStream($stream, $site, $cam, $playlist, $relay, $endpoint);

		}

		writeUnity($promptDBHost, $promptDBUser. $promptDBPass, $promptDBName, $promptFQDN, $promptUnity);


}else{
	print "* Exiting The Installer -> Try Again \n";

}

sub writeFTPConfig($promptIP){

			`cp /home/videouser/VIDEO_SERVER/SOURCE/vsftpd.conf /home/videouser/VIDEO_SERVER/TMP/`;
                        print "* Writing FTP Config -> ";
                        open (MYFILE, '>>/home/videouser/VIDEO_SERVER/TMP/vsftpd.conf');
                        print MYFILE "##########################################\n";
                        print MYFILE "#### FTP Options - LIVS Config\n";
                        print MYFILE "#### Generated Using The Unity Installer\n";
                        print MYFILE "##########################################\n\n";			
			print MYFILE "pasv_enable=YES\n";
			print MYFILE "port_enable=YES\n";
			print MYFILE "accept_timeout=240\n";
			print MYFILE "connect_timeout=240\n";
			print MYFILE "pasv_max_port=20000\n";
			print MYFILE "pasv_min_port=10000\n";
			print MYFILE "parv_address=$promptIP\n";
			print MYFILE "#### End Custom Config ####\n";
			close (MYFILE);
			print "Replacing Existing Config ->\n";
			`rm -rf /etc/vsftpd/vsftpd.conf`;
			`mv /home/videouser/VIDEO_SERVER/TMP/vsftpd.conf /etc/vsftpd/vsftpd.conf`;
			print "FTP Config Setup Successfully \n";

}

sub writeStream($stream, $site, $cam, $playlist, $relay, $endpoint){

			print "* Writing Stream$stream Config -> ";
                        open (MYFILE, '>/home/videouser/VIDEO_SERVER/CONFIGS/STREAM'.$stream.'.inc');
                        print MYFILE "##########################################\n";
                        print MYFILE "#### Live Stream - LIVS Config\n";
                        print MYFILE "#### Generated Using The Unity Installer\n";
                        print MYFILE "##########################################\n\n";
                        print MYFILE "#### Playlist\n";
                        print MYFILE "\$playlist = '$playlist'\;\n";
                        print MYFILE "#### Site Name\n";
                        print MYFILE "\$site = '$site'\;\n";
                        print MYFILE "#### Camera Name\n";
                        print MYFILE "\$cam = '$cam'\;\n";
                        print MYFILE "#### Stream ID\n";
                        print MYFILE "\$feed = '$stream'\;\n";
                        print MYFILE "#### Relay URL\n";
                        print MYFILE "\$relay = '$relay'\;\n";
                        print MYFILE "#### Relay Endpoint\n";
                        print MYFILE "\$endpoint = '$endpoint'\;\n";
                        close (MYFILE);
                        print "Stream Config Setup Successfully \n";
			sleep 1;
			`chmod 400 /home/videouser/VIDEO_SERVER/CONFIGS/STREAM$stream.inc`;
			`chown videouser:videouser /home/videouser/VIDEO_SERVER/CONFIGS/STREAM$stream.inc`;

}

sub writeUnity($promptDBHost, $promptDBUser. $promptDBPass, $promptDBName, $promptFQDN, $promptUnity){

                        print "* Writing Unity Relay Stream Config -> ";
			open (MYFILE, '>/var/www/html/$promptUnity/includes/config.php');
                        print MYFILE "<?php\n";
			print MYFILE "//##########################################\n";
                        print MYFILE "//#### Master - Unity Config\n";
                        print MYFILE "//#### Generated Using The Unity Installer\n";
                        print MYFILE "//##########################################\n\n";
                        print MYFILE "//#### MySQL DB Credentials\n";
			print MYFILE "\$hostname_unity = \'$promptDBHost\'\;\n";
                        print MYFILE "\$username_unity = \'$promptDBUser\'\;\n";
                        print MYFILE "\$password_unity = \'$promptDBPass\'\;\n";
                        print MYFILE "\$database_unity = \'$promptDBName\'\;\n";
                        print MYFILE "\n//#### Global Stream Info\n";
                        print MYFILE "\$get_url = \$_SERVER[\'REQUEST_URI\']\;\n";
			print MYFILE "\$pieces = explode(\'/\', \$get_url)\;\n";
                        print MYFILE "\$location = \$pieces[1]\;\n";
			print MYFILE "\$stream_port = \'1935\'\;\n";
                        print MYFILE "\n//#### Global Stream Info\n";
			if(-e "/home/videouser/VIDEO_SERVER/CONFIGS/STREAM01.inc"){
			require "/home/videouser/VIDEO_SERVER/CONFIGS/STREAM01.inc";
			print MYFILE "\$stream_1_IP = \'$relay\'\;\n";
			print MYFILE "\$stream_1_url = \'live\'\;\n";
			print MYFILE "\$stream_1_file = \'$endpoint\'\;\n";
			}
                        if(-e "/home/videouser/VIDEO_SERVER/CONFIGS/STREAM02.inc"){
                        require "/home/videouser/VIDEO_SERVER/CONFIGS/STREAM02.inc";
                        print MYFILE "\$stream_2_IP = \'$relay\'\;\n";
                        print MYFILE "\$stream_2_url = \'live\'\;\n";
                        print MYFILE "\$stream_2_file = \'$endpoint\'\;\n";
                        }			
			print MYFILE "?>";
                        close (MYFILE);
			sleep 1;
                        print "Stream Relay Config Setup Successfully \n";
			`chmod 400 /var/www/html/$promptUnity/includes/config.php`;
			`chown apache:apache /var/www/html/$promptUnity/includes/config.php`;

			print "* Writing Unity Database Config -> ";
                        open (MYFILE, '>/var/www/html/$promptUnity/unity_core/Config.php');
                        print MYFILE "<?php\n";
                        print MYFILE "//##########################################\n";
                        print MYFILE "//#### Core - Unity DB Config\n";
                        print MYFILE "//#### Generated Using The Unity Installer\n";
                        print MYFILE "//##########################################\n\n";
                        print MYFILE "//#### MySQL DB Credentials\n";
                        print MYFILE "\$dbhost = \'$promptDBHost\'\;\n";
                        print MYFILE "\$dbuser = \'$promptDBUser\'\;\n";
                        print MYFILE "\$dbpass = \'$promptDBPass\'\;\n";
                        print MYFILE "\$dbname = \'$promptDBName\'\;\n";
                        print MYFILE "?>";
                        close (MYFILE);
                        print "Database Config Setup Successfully \n";
			sleep 1;
			`chmod 400 /var/www/html/$promptUnity/unity_core/Config.php`;
			`chown apache:apache /var/www/html/$promptUnity/unity_core/Config.php`;
									
                        print "* Writing Unity Core Config -> ";
                        open (MYFILE, '>/var/www/html/$promptUnity/unity_core/Unity_Config.xml');
                        print MYFILE "unitySystemName:$promptUnity\n";
                        print MYFILE "unitySubdomain:$promptFQDN\n";
                        print MYFILE "unityRootpath:/var/www/html/\n";
                        print MYFILE "unityRootDirectory:$promptUnity/\n";
			print MYFILE "unityWebDirectory:DOC_Web/\n";
			print MYFILE "unitySplashPage:/var/www/html/$promptUnity\n";
			print MYFILE "unityExcludeDirectory:/var/www/html/$promptUnity/DOC_Web/Daily_Progress_Reports/Photon/Files/Incoming_reports\n";
			print MYFILE "defaultProxyImage:/var/www/html/$promptUnity/unity_core/images/defaultProxyImage.jpg\n";
			print MYFILE "unityArchiveDirectory:Daily_Report_Archive\n";
			print MYFILE "unityDefaultTags:deck-platform-conductor-hot-review-\n";
			print MYFILE "unityDefaultAdminPassword:r00t\n";
			print MYFILE "xResProxy:640\n";
			print MYFILE "yResProxy:480\n";
			print MYFILE "xRes:1024\n";
			print MYFILE "yRes:768\n";
                        close (MYFILE);
			sleep 1;
                        print "Core Config Setup Successfully \n";
			`chmod 400 /var/www/html/$promptUnity/unity_core/Unity_Config.xml`;
			`chown apache:apache /var/www/html/$promptUnity/unity_core/Unity_Config.xml`;

}

sub promptUser {

   #-------------------------------------------------------------------#
   #  two possible input arguments - $promptString, and $defaultValue  #
   #  make the input arguments local variables.                        #
   #-------------------------------------------------------------------#

   local($promptString,$defaultValue) = @_;

   #-------------------------------------------------------------------#
   #  if there is a default value, use the first print statement; if   #
   #  no default is provided, print the second string.                 #
   #-------------------------------------------------------------------#

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)


   #------------------------------------------------------------------#
   # remove the newline character from the end of the input the user  #
   # gave us.                                                         #
   #------------------------------------------------------------------#

   chomp;

   #-----------------------------------------------------------------#
   #  if we had a $default value, and the user gave us input, then   #
   #  return the input; if we had a default, and they gave us no     #
   #  no input, return the $defaultValue.                            #
   #                                                                 # 
   #  if we did not have a default value, then just return whatever  #
   #  the user gave us.  if they just hit the <enter> key,           #
   #  the calling routine will have to deal with that.               #
   #-----------------------------------------------------------------#

   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}
