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

$svg->init;

my $circle = Circle->new(
    cx => 100, cy => 100, r => 50
    );

$svg->w_circle($circle, $circle_style);

$svg->finalize;
