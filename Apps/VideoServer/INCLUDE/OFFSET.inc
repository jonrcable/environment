### These Are the Stream Offsets

## Offset the delay beyond the buffer latency if things happen to quickly
$stream_offset = 3;

## Offset the sample rate of the vsftpd logs. 100 lines is about 12 samples
## Smaller sample rates mean more up to the sec averages. LArger if it jumps around to much
$log_offset = 20;

## Add this to the network offset MAX 5min or 300sec
$buffer_offset = 90;
