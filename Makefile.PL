use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $mainfile = 'lib/Convert/UU.pm';
WriteMakefile(
    'NAME'	=> 'Convert::UU',
    'VERSION_FROM' => $mainfile,
    'EXE_FILES' => [qw(puudecode puuencode)],
    dist => { 
	     PREOP => "co -l README && pod2text $mainfile > README && ci -u README",
	    },
);
