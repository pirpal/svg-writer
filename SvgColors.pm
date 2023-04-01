#!/usr/bin/perl

#--------------------------------------------------------
# module SvgColors.pm
#
# This module is intended to be used to write SVG colors
# properties to a SVG file ("fill", "stroke").
#
# You can use either 24-bits (6 digits, RGB) or 32-bits
# (8 digits, RGBA) hexadecimal values to define your
# colors.
# But keep in mind that you cannot call:
# `color_str($color, "rgba")` on a 6 digits value.
#
# The SVG supported formats are:
# - "rgb" ...... "rgb(255,0,255)"
# - "rgba" ..... "rgba(255,0,255,1.0)"
# - "hex" ...... "#ff00ff"
#
# Please note that:
# - with "rgba" format, the alpha value is a float
#   between 0 and 1, not an integer between 0 and 255
# - SVG does not support hexadecimal alpha value
# - SVG also gives the possibility to write a 3 digits
#   hexa color '#rgb', but it's not implemented here
#--------------------------------------------------------


package SvgColors;
use v5.36;
use Exporter 'import';
our @EXPORT = qw(color_str SvgStyle);

#---------------------------------------
our $CHANNEL_A = 0;
our $CHANNEL_B = 1;
our $CHANNEL_G = 2;
our $CHANNEL_R = 3;
                                                       
our @MASKS = (
    0x000000FF, # Alpha
    0x0000FF00, # Blue
    0x00FF0000, # Green
    0xFF000000, # Red
);

use constant {
    HEX_FMT  => "hex",
    RGB_FMT  => "rgb",
    RGBA_FMT => "rgba"
};

sub get_channel($color, $channel) {
    # Return decimal value of $CHANNEL in $COLOR
    return ($color & $MASKS[$channel]) >> 8 * $channel;
}

sub fmt_hex($n) {
    # Add left zero when $N < 16
    my $str = undef;
    if ($n < 16) {
        $str = sprintf("0%x", $n);
    } else {
        $str = sprintf("%x", $n);
    }
    return $str;
}

sub color_str($color, $fmt) {
    # $COLOR: 32-bits (8 digits) hexadecimal integer
    # $FMT  : "rgba" | "rgb" | "hex"
    my $r = get_channel($color, $CHANNEL_R);
    my $g = get_channel($color, $CHANNEL_G);
    my $b = get_channel($color, $CHANNEL_B);
    
    if ($fmt eq RGBA_FMT) {
	my $a = get_channel($color, $CHANNEL_A);
	my $a_ratio = $a / 255.0;
	return sprintf("rgba(%d,%d,%d,%.1f)", $r, $g, $b, $a_ratio);
    } elsif ($fmt eq RGB_FMT) {
	return sprintf("rgb(%d,%d,%d)", $r, $g, $b);
    } elsif ($fmt eq HEX_FMT) {
	my $sr = fmt_hex($r);
	my $sg = fmt_hex($g);
	my $sb = fmt_hex($b);
	return sprintf("#%s%s%s", $sr, $sg, $sb);
    } else {
	die "[ERR] FMT must be: RGB_FMT | RGBA_FMT | HEX_FMT\n"; 
    }
}

#---------------------------------------
package SvgStyle;
use Moose;

has 'fill', (is => 'ro', isa => 'Int');
has 'stroke', (is => 'ro', isa => 'Int');
has 'stroke_w', (is => 'ro', isa => 'Num');
has 'color_mode', (is => 'ro', isa => 'Str');

#___
1;
