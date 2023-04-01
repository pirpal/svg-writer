#!/usr/bin/perl

use v5.36;

use lib '.'; # dev only
use SvgWriter;
use SvgGeometry;

our %PALETTE = (
    BLACK  => 0x000000FF,
    BLUE   => 0x1364FFFF,
    GREY   => 0x808080FF,
    RED    => 0xFF3749FF,
    WHITE  => 0xFFFFFFFF,
    YELLOW => 0xFFDB10FF,
    );

my $circle_style = SvgStyle->new(
    fill   => $PALETTE{YELLOW},
    stroke => $PALETTE{GREY},
    stroke_w => 1.0,
    color_mode => "hex"
    );

my $svg = SvgFile->new(
    path   => "out.svg",
    width  => 400,
    height => 400,
    bg_color => $PALETTE{WHITE}
    );


my $circle = Circle->new(
    center => Vec2->new(x => 200, y => 200),
    radius => 50
    );

$svg->init;

#------------------------------
open(my $fh, ">>", $svg->path) or die "Cannot open file: $!";


$svg->w_circle($fh, $circle, $circle_style);

$svg->finalize($fh);

close($fh) or die "Cannot close file: $:";
#-----------------------------
