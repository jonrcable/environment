#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Getopt::Std;
use POSIX;

### Define our client include file
$opt_s = "0";
$opt_p = "0";
getopt('s:p:');
chomp($opt_s);
chomp($opt_p);

if($opt_p eq 'server'){

	if($opt_s eq 'start'){

        print "### Starting Server Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./servicecheck.pl -s start`;
        print "\n### Starting Network Mounts ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./mountcheck.pl -s start`;
        print "\n### Starting Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s start`;

	}elsif($opt_s eq 'stop'){

		print "### Stopping Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s stop`;
		print "\n### Disconnecting Server Mounts ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./mountcheck.pl -s stop`;
		print "\n### Stopping Server Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./servicecheck.pl -s stop`;

	}elsif($opt_s eq 'restart'){

		print "### Stopping Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s stop`;
		print "\n### Disconnecting Server Mounts ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./mountcheck.pl -s stop`;
        print "\n### Stopping Server Services ###\n\n";
		print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./servicecheck.pl -s stop`;

		print "### Starting Server Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./servicecheck.pl -s start`;
        print "\n### Starting Network Mounts ###\n\n";
		print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./mountcheck.pl -s start`;
        print "\n### Starting Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s start`;

	}else{

        print "### Server Status ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./servicecheck.pl -s status`;
		print "\n### Network Mount Status ###\n\n";
		print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./mountcheck.pl -s status`;
		print "\n### Streaming Status ###\n\n";
		print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s status`;

	}

}elsif($opt_p eq 'stream'){

    if($opt_s eq 'start'){

        print "### Starting Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s start`;

    }elsif($opt_s eq 'stop'){

        print "### Stopping Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s stop`;

    }elsif($opt_s eq 'restart'){

        print "### Stopping Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s stop`;
        print "### Starting Streaming Services ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s start`;

    }else{

        print "### Streaming Status ###\n\n";
        print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./streamcheck.pl -s status`;

    }

}elsif($opt_p eq 'backup'){

    print "### Making Server Backup ###\n\n";
    print `cd /home/videouser/VIDEO_SERVER/SCRIPTS; ./backupsql.pl`;

}elsif($opt_p eq 'restore'){

}else{

    print "\n";
    print "#############################\n";
    print "UNITY/LIVS Service Management\n";
    print "#############################\n";
    print "\n";
    print "mngserver.pl -p PROCESS -s STATUS\n";
    print "-p server (Global Server Controls) -s (start/stop/restart/status)\n";
    print "-p steam (Broadcast Server Controls) -s (start/stop/restart/status)\n";
    print "-p backup (Backup Existing Config/Database)\n";
    print "-p restore (Restore Existing Config/Database)\n";
    print "\nUsage Examples\:\n";
    print "(server status) ./mngserver.pl -p server -s status\n";
    print "(start server) ./mngserver.pl -p server -s start\n";
    print "(restart streams) ./mngserver.pl -p stream -s restart\n";
    print "(make backup) ./mngserver.pl -p backup\n";
    print "\n";

}
