#!/usr/bin/perl
use Getopt::Std;
use POSIX;
use Time::Local;

$this = `tail /var/streaming/playlists/STREAM02/STREAM02.log | grep "3default2.mp4"`;
if($this eq ''){
print 'error';
}else{
print $this;
}
