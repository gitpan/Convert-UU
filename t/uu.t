# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use strict;
use vars qw($loaded);

BEGIN {print "1..5\n";}
END {print "not ok 1\n" unless $loaded;}
use Convert::UU;
$loaded = 1;
print "ok 1\n";
$^W = 1;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):


use Convert::UU 'uuencode';

my $forth = bytometer(3000);
my $uu = uuencode($forth,"foo","644");
my $back = Convert::UU::uudecode($uu);
if ($forth eq $back){
    print "ok 2\n";
} else {
    print "not ok 2: forth[$forth] uu[$uu] back[$back]\n";
}

if (open F, "MANIFEST") {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}
undef $/;
$forth = <F>;
open F, "MANIFEST";
use Convert::UU 'uudecode';
if ($back = uudecode(uuencode(*F)) and $back eq $forth) {
    print "ok 4\n";
} else {
    print "not ok 4: forth[$forth] back[$back]\n";
}

$forth = [ "begin 644 foo\n",
         '$9F]O"@``' . "\n",
         "end\n" ];

if (($back=uudecode($forth)) eq "foo\n") {
    print "ok 5\n";
} else {
    print "not ok 5: forth[forth\n] back[$back]\n";
}

sub bytometer ( $ ) {
    my($byte) = @_;
    my($result,$i) = "";
    for ($i=5;$i<=$byte;$i+=5) {
	if ( $i==5 || substr($i,-2) eq "05" && $i<10000 ) {
	    $result .=  join "", "\n", "." x (4-length($i)), $i;
	} elsif ( $i<=10000 ) {
	    $result .=  join "", "." x (5-length($i)), $i;
	} elsif ( substr($i,-2) eq "10" ) {
	    $result .=  join "", "\n", "." x (9-length($i)), $i;
	} elsif ( substr($i,-1) eq "0" ) {
	    $result .=  join "", "." x (10-length($i)), $i;
	}
    }
    $result .= "." x ($byte%5);
    $result;
}
