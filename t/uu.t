# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN {print "1..5\n";}
END {print "not ok 1\n" unless $loaded;}
use Convert::UU;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):


use Convert::UU 'uuencode';
if (($foo=uuencode("foo\n","foo","644")) eq 'begin 644 foo
$9F]O"@``
end
'){
    print "ok 2\n";
} else {
    print "not ok 2: >$foo<\n";
}

if (open F, "MANIFEST") {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}
undef $/;
$foo = <F>;
open F, "MANIFEST";
use Convert::UU 'uudecode';
if ($bar = uudecode(uuencode(*F)) and $bar eq $foo) {
    print "ok 4\n";
} else {
    print "not ok 4: foo [$foo] bar [$bar]\n";
}

$foo = [ "begin 644 foo\n",
         '$9F]O"@``' . "\n",
         "end\n" ];

if (($bar=uudecode($foo)) eq "foo\n") {
    print "ok 5\n";
} else {
    print "not ok 5: foo [foo\n] bar [$bar]\n";
}