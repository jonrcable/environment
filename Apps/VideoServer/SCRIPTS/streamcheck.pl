#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Std;
use POSIX;

### Define our client include file
$opt_s = "0";
getopt('s:');
chomp($opt_s);

my $dir = '/home/videouser/VIDEO_SERVER/CONFIGS/';

opendir(DIR, $dir) or die $!;

while (my $file = readdir(DIR)) {

    # Use a regular expression to ignore files beginning with a period
    next if ($file =~ m/^\./);
	
	$streamConfig = $file;  
 
	if($opt_s eq 'start'){

		# streamStop($streamConfig);
		streamStart($streamConfig);

	}elsif($opt_s eq 'stop'){

		streamStop($streamConfig);
		exit;

	}elsif($opt_s eq 'proc'){
		
		streamProc($streamConfig);

	}else{

		streamStatus($streamConfig);

	}
}

closedir(DIR);

sub streamStart($streamConfig){
    
	require("/home/videouser/VIDEO_SERVER/CONFIGS/$streamConfig");
	if(-e "/var/streaming/playlists/$playlist/$playlist.config"){
		print "Playlist $playlist Exists -> ";

        `cd /home/videouser/VIDEO_SERVER/SCRIPTS/; nohup ./videoserver.pl -c $streamConfig >/dev/null 2>&1 &`;
        print " Playlist $playlist has started successfully \n";
		
	}else{

        print " Playlist $playlist not created in Darwin \n";

    }

}

sub streamStop($streamConfig){
    
        require("/home/videouser/VIDEO_SERVER/CONFIGS/$streamConfig");
        if(-e "/var/streaming/playlists/$playlist/$playlist.config"){

		    # Stop VideoServer
            `killall videoserver.pl`;
			sleep 1;
                # my $pidPlaylist = `pidof ./PlaylistBroadcaster`;
                # if($pidPlaylist){
                #        `kill $pidPlaylist`;
                #        sleep 1;
                # }
                # `rm -rf /var/streaming/playlists/*`;
            print "* All Playlists have been stopped...\n";

        }else{

            print "* All Playlists are stopped...\n";

        }

}

sub streamStatus($streamConfig){

    require("/home/videouser/VIDEO_SERVER/CONFIGS/$streamConfig");

    if(-e "/var/streaming/playlists/$playlist/$playlist.config"){

        `ps -ef | grep /var/streaming/playlists/$playlist/$playlist.config | grep -v grep`;
        if($? != 0){
            print "* Playlist $playlist playlist error...\n";
            # `cd /usr/local/bin/; ./PlaylistBroadcaster -d /var/streaming/playlists/$playlist/$playlist.config`;
            # `touch /var/streaming/playlists/$playlist/.started`;
        }else{
            print "* Darwin $playlist is running...\n";
        }

    }else{

        print "* Playlist $playlist is stopped...\n";

    }

    `ps -ef | grep "videoserver.pl -c $streamConfig" | grep -v grep`;

    if($? != 0){

        print "* Server $playlist is stopped...\n";

    }else{

        print "* Server $playlist is running...\n";

    }

}

sub streamProc($streamConfig){

    require("/home/videouser/VIDEO_SERVER/CONFIGS/$streamConfig");
    if(-e "/var/streaming/playlists/$playlist/$playlist.config"){

        `ps -ef | grep /var/streaming/playlists/$playlist/$playlist.config | grep -v grep`;
        if($? != 0){

            print "* Playlist $playlist playlist error...\n";
            # `cd /usr/local/bin/; ./PlaylistBroadcaster -d /var/streaming/playlists/$playlist/$playlist.config`;
            # `touch /var/streaming/playlists/$playlist/.started`;

        }else{

            print "* Playlist $playlist is running...\n";

        }

    }else{

        print "* Playlist $playlist is stopped...\n";

    }

    `ps -ef | grep "videoserver.pl -c $streamConfig" | grep -v grep`;
    if($? != 0){

        print "* Server $playlist is stopped...\n";
        print "Restarting $playlist...\n";
        self::streamStart($streamConfig);

    }else{

        print "* Server $playlist is running...\n";

    }

}
