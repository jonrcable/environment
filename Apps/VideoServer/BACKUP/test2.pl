#!/usr/bin/perl -w
use strict;

sub round_up_tens($) {

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

print "-24 => " . round_up_tens(-24) . "\n";
print "-14 => " . round_up_tens(-14) . "\n";
print "-10 => " . round_up_tens(-10) . "\n";
print "-4 => " . round_up_tens(-4) . "\n";
print "0 => " . round_up_tens(0) . "\n";
print "4 => " . round_up_tens(4) . "\n";
print "7 => " . round_up_tens(7) . "\n";
print "10 => " . round_up_tens(10) . "\n";
print "14 => " . round_up_tens(14) . "\n";
print "144 => " . round_up_tens(144) . "\n";
