#!/usr/bin/perl

use v5.36;

use lib '.'; # dev only
use SvgWriter;
use SvgGeometry;


# --- define: out SVG file format in pixels:
use constant OUT_W => 400;
use constant OUT_H => 400;


# --- define: colors and styles
our %PALETTE = (
    NUll_COLOR => 0x00000000, # 
    BLACK      => 0x000000FF,  # #000000
    BLUE       => 0x1364FFFF,  # #1364ff
    BLUE_50    => 0x1364FF80,  # #1364ff - 50% alpha
    GREEN_50   => 0x10c00880,  # #10c008 - 50% alpha
    GREY       => 0x808080FF,  # #808080
    PURPLE_50  => 0xF0A0C080,  # #f0a0c0 - 50% alpha
    RED        => 0xFF3749FF,  # #ff3749
    WHITE      => 0xFFFFFFFF,  # #ffffff
    YELLOW     => 0xFFDB10FF,  # #ffdb10
    );


my $circle_style = SvgStyle->new(
    fill   => $PALETTE{GREEN_50},
    stroke => $PALETTE{GREEN_50},
    stroke_w => 1.0,
    color_mode => "rgba"
    );

my $rect_style = SvgStyle->new(
    fill   => $PALETTE{BLUE_50},
    stroke => $PALETTE{BLACK},
    stroke_w => 1.0,
    color_mode => "rgba"
    );

my $line_style = SvgStyle->new(
    stroke => $PALETTE{BLACK},
    stroke_w => 1.0,
    color_mode => "hex"
    );

my $triangle_style = SvgStyle->new(
    fill => $PALETTE{YELLOW},
    stroke => $PALETTE{PURPLE_50},
    stroke_w => 4.0,
    color_mode => "rgba"
    );

# --- define: SvgFile
my $svg = SvgFile->new(
    path   => "out.svg",
    width  => OUT_W,
    height => OUT_W,
    bg_color => $PALETTE{WHITE}
    );
$svg->init;

# --- define: shapes
my $circle = Circle->new(
   id => "circle-1",
   center => Vec2->new(x => 200, y => 200),
   radius => 100
   );

my $rect = Rect->new(
    id => "rect-1",
    origin => Vec2->new(x => 80, y => 80),
    width => 64,
    height => 64,
    round => Vec2->new(x => 12, y => 12)
    );

my $hex = RegPolygon->new(
    id => "hexagon",
    center => Vec2->new(x => OUT_W / 2, y => OUT_H / 2),
    radius => 80.0,
    sides  => 6,
    flat   => 1
    );

open(my $fh, ">>", $svg->path) or die "Can't open file: $!";

$svg->w_circle($fh, $circle, $circle_style);
$svg->w_rect($fh, $rect, $rect_style);
$svg->w_reg_polygon($fh, $hex, $line_style);

my $x = 0.0;
my $y = 0.0;
my $tr_radius = 20.0;
foreach (0..10) {
    my $id_str = "polyg-" . "$_";
    my $iso_tr = RegPolygon->new(
	id => $id_str,
	center => Vec2->new(x => $tr_radius + ($tr_radius / 2) + $tr_radius * $_,
			    y => OUT_H - (OUT_H / 10)),
	radius => $tr_radius,
	sides => 3,
	flat => 1);
    $svg->w_reg_polygon($fh, $iso_tr, $rect_style);
}


$svg->finalize($fh);

close($fh) or die "Xan't close file: $!";

