package Convert::UU;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);
use Carp 'croak';

require Exporter;

@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(
	     uudecode uuencode
);
$VERSION = '0.01';


# Preloaded methods go here.

#
#  From comp.lang.perl 3/1/95.
#  Posted by Hans Mulder (hansm@wsinti05.win.tue.nl)
#

sub uuencode {
    croak("Usage: uuencode( {string|filehandle} [,filename] [, mode] )")
      unless(@_ >= 1 && @_ <= 3);

    my($in,$file,$mode) = @_;
    $mode ||= "644";
    $file ||= "uuencode.uu";

    my($chunk,$result,$r);
    $result = "";
    if (
	ref(\$in) eq "GLOB" or 
	ref($in) eq 'GLOB' or 
	ref($in) eq 'FileHandle'
       ) {
	local $^W = 0; # Why did I get use of undefiend value here ???
	while (defined($r = read($in,$chunk,45)) && $r > 0) {
	    $result .= uuencode_chunk($chunk);
	}
    } elsif (ref(\$in) eq "SCALAR") {
	while ($in =~ s/(.{1,45})//s) {
	    $result .= uuencode_chunk($1);
	}
    }
    return "begin $mode $file\n" . $result . "end\n";

}

sub uuencode_chunk {
    my($string) = shift;
# for the Mac?
#    my($mod3) = length($string) % 3;
#    $string .= "\0", $mod3 -= 3 if $mod3;
    my $encoded_string = pack("u", $string);           # unix uuencode
# for the Mac?
#    $encoded_string =~ s/.//;                       # remove length byte
#    chop($encoded_string);                          # remove trailing \n
#    $encoded_string =~ tr#`!-_#A-Za-z0-9+/#;        # tr to mime alphabet
#    substr($encoded_string, $mod3) =~ tr/A/=/;      # adjust padding
    return $encoded_string;
}

sub uudecode {
    croak("Usage: uudecode( {string|filehandle}) ")
      unless(@_ == 1);
    my($in) = @_;

    my($result,$file,$mode);
    $result = $mode = $file = "";
    if (ref(\$in) eq "GLOB" or ref($in) eq 'GLOB' or ref($in) eq 'FileHandle') {
	while (<$in>) {
	    if ($file eq "" and !$mode){
		($mode,$file) = /^begin\s+(\d+)\s+(\S+)/ ;
		next;
	    }
	    last if /^end/;
	    $result .= uudecode_chunk($_);
	}
    } elsif (ref(\$in) eq "SCALAR") {
	while ($in =~ s/(.*?\n)//s) {
	    my $line = $1;
	    if ($file eq "" and !$mode){
		($mode,$file) = $line =~ /^begin\s+(\d+)\s+(\S+)/ ;
		next;
	    }
	    next if $file eq "" and !$mode;
	    last if $line =~ /^end/;
	    $result .= uudecode_chunk($line);
	}
    }
    wantarray ? ($result,$file,$mode) : $result;
}

sub uudecode_chunk {
    my($chunk) = @_;
    return "" if $chunk =~ /^(--|\#|CREATED)/;
    my $string = substr($chunk,0,int((((ord($chunk) - 32) & 077) + 2) / 3)*4+1);
#    warn "DEBUG: string [$string]";
#    my $return = unpack("u", $string);
#    warn "DEBUG: return [$return]";
#    $return;
    local $^W = 0; # Bug in perl5.002 ? I get a Use of unini.. with ANY $string
    return unpack("u", $string);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Convert::UU, uuencode, uudecode - Perl module for uuencode and uudecode

=head1 SYNOPSIS

  use Convert::UU qw(uudecode uuencode);
  $encoded_string = uuencode($string,[$filename],[$mode]);
  ($string,$filename,$mode) = uudecode($string);
  $string = uudecode($string); # in scalar context

=head1 DESCRIPTION

uuencode() takes as the first argument a scalar that is to be
uuencoded. Alternatively a filehandle may be passed that must be
opened for reading. It returns the uuencoded string including begin
and end. Second and third argument are optional and specify filename and
mode. If unspecified these default to "uuencode.uu" and 644.

uudecode() takes a string as argument which will be uudecoded. If the
argument is a filehandle this will be read instead. Leading and
trailing garbage will be ignored. The function returns the uudecoded
string for the first begin/end pair. In array context it returns an
array whose first element is the uudecoded string, the second is the
filename and the third is the mode.

=head1 EXPORT

Both uudecode and uuencode are in @EXPORT_OK.

=head1 PORTABILITY

No effort has been made yet to port this module to non UNIX operating
systems. Volunteers are welcome.

=head1 AUTHOR

Andreas Koenig E<lt>andreas.koenig@mind.deE<gt>. With code stolen from
Hans Mulder E<lt>hansm@wsinti05.win.tue.nlE<gt> and Randal L. Schwartz
E<lt>merlyn@teleport.comE<gt>.

=head1 SEE ALSO

puuencode(1), puudecode(1) for examples of how to use this module.

=cut
