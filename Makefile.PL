use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Convert::UU',
    'VERSION_FROM' => 'lib/Convert/UU.pm', # finds $VERSION
    'PL_FILES' => {qw(puudecode.PL puudecode puuencode.PL puuencode)},
    'EXE_FILES' => [qw(puudecode puuencode)],
    dist => { COMPRESS => 'gzip -9f' },
);
