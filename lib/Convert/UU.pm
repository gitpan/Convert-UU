package Convert::UU;

use strict;
BEGIN {require 5.004} # m//gc
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
$VERSION = '0.40';

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

    my($chunk,@result,$r);
    if (
	ref($in) eq 'IO::Handle' or
	ref(\$in) eq "GLOB" or
	ref($in) eq "GLOB" or
	ref($in) eq 'FileHandle'
       ) {
        # local $^W = 0; # Why did I get use of undefined value here ?
	binmode($in);
	while (defined($r = read($in,$chunk,45)) && $r > 0) {
	    push @result, uuencode_chunk($chunk);
	}
    } elsif (ref(\$in) eq "SCALAR") {
        pos($in)=0;
	while ($in =~ m/\G(.{1,45})/sgc) {
	    push @result, uuencode_chunk($1);
	}
    }
    join "", "begin $mode $file\n", @result, "end\n";
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
    $encoded_string;
}

sub uudecode {
    croak("Usage: uudecode( {string|filehandle|array ref}) ")
      unless(@_ == 1);
    my($in) = @_;

    my(@result,$file,$mode);
    $mode = $file = "";
    if (
	ref($in) eq 'IO::Handle' or
	ref(\$in) eq "GLOB" or
	ref($in) eq "GLOB" or
	ref($in) eq 'FileHandle'
       ) {
	local($\) = "\n";
	binmode($in);
	while (<$in>) {
	    if ($file eq "" and !$mode){
		($mode,$file) = ($1, $2) if /^begin\s+(\d+)\s+(\S+)/ ;
		next;
	    }
	    last if /^end/;
	    push @result, uudecode_chunk($_);
	}
    } elsif (ref(\$in) eq "SCALAR") {
	while ($in =~ m/\G(.*?(\n|\r|\r\n|\n\r))/gc) {
	    my $line = $1;
	    if ($file eq "" and !$mode){
		($mode,$file) = $line =~ /^begin\s+(\d+)\s+(\S+)/ ;
		next;
	    }
	    next if $file eq "" and !$mode;
	    last if $line =~ /^end/;
	    push @result, uudecode_chunk($line);
	}
    } elsif (ref($in) eq "ARRAY") {
	my $line;
	foreach $line (@$in) {
	    if ($file eq "" and !$mode){
		($mode,$file) = $line =~ /^begin\s+(\d+)\s+(\S+)/ ;
		next;
	    }
	    next if $file eq "" and !$mode;
	    last if $line =~ /^end/;
	    push @result, uudecode_chunk($line);
	}
    }
    wantarray ? (join("",@result),$file,$mode) : join("",@result);
}

sub uudecode_chunk {
    my($chunk) = @_;
#    return "" if $chunk =~ /^(--|\#|CREATED)/; # the "#" was an evil
                                                # bug: a "#" in column
                                                # one is legal!
    return "" if $chunk =~ /^(?:--|CREATED)/;
    my $string = substr($chunk,0,int((((ord($chunk) - 32) & 077) + 2) / 3)*4+1);
#    warn "DEBUG: string [$string]";
#    my $return = unpack("u", $string);
#    warn "DEBUG: return [$return]";
#    $return;

    my $ret = unpack("u", $string);
    defined $ret ? $ret : "";
}

1;

__END__

=head1 NAME

Convert::UU, uuencode, uudecode - Perl module for uuencode and uudecode

=head1 SYNOPSIS

  use Convert::UU qw(uudecode uuencode);
  $encoded_string = uuencode($string,[$filename],[$mode]);
  ($string,$filename,$mode) = uudecode($string);
  $string = uudecode($string); # in scalar context

=head1 DESCRIPTION

uuencode() takes as the first argument a string that is to be
uuencoded. Note, that it is the string that is encoded, not a
filename. Alternatively a filehandle may be passed that must be opened
for reading. It returns the uuencoded string including C<begin> and
C<end>. Second and third argument are optional and specify filename and
mode. If unspecified these default to "uuencode.uu" and 644.

uudecode() takes a string as argument which will be uudecoded. If the
argument is a filehandle this handle will be read instead. If it is a
reference to an ARRAY, the elements are treated like lines that form a
string. Leading and trailing garbage will be ignored. The function
returns the uudecoded string for the first begin/end pair. In array
context it returns an array whose first element is the uudecoded
string, the second is the filename and the third is the mode.

=head1 EXPORT

Both uudecode and uuencode are in @EXPORT_OK.

=head1 AUTHOR

Andreas Koenig E<lt>andreas.koenig@mind.deE<gt>. With code integrated
that was posted to USENET from Hans Mulder
E<lt>hansm@wsinti05.win.tue.nlE<gt> and Randal L. Schwartz
E<lt>merlyn@teleport.comE<gt>.

=head1 SEE ALSO

puuencode(1), puudecode(1) for examples of how to use this module.

=cut
