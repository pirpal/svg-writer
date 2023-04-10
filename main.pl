#!/usr/bin/perl

use v5.36;

use lib '.';
use SvgGeometry;
use SvgWriter;
use List::Util 'shuffle';

use constant {
    SVG_H => 400,
    SVG_W => 400,
};

sub rand_range($min, $max) {
    return 10 + int rand($max - $min +1);
}

our %PALETTE = (
    #           0xrrggbbaa
    BLUE_50   => 0x1030C080, # #1030c0 a 50%
    GOLD_50   => 0xE0803050, # #e08030
    GREEN_50  => 0x30A01080, # #30a010 a 50%
    ORANGE_50 => 0xD0301080, # #d03010 a 50%
); 

my $svg = SvgFile->new(
    path   => "out.svg",
    width  => SVG_W,
    height => SVG_H,
    bg_color => 0x808080FF
    );
$svg->init;


my @color_keys = keys %PALETTE;
my $min_shape_w = 32;
my $max_shape_w = 96;
my $stroke_w = 1;
my $min_x = $min_shape_w;
my $min_y = $min_shape_w;
my $max_x = SVG_W - $min_shape_w;
my $max_y = SVG_H - $min_shape_w;

open(my $fh, ">>", $svg->path) or die "[ ERR ] FileOpenError $!";

my $shapes_nb = rand_range(40, 100);

print "Writing $shapes_nb random circle to ", $svg->path, "...\n";

foreach (1..$shapes_nb) {
    my @shuf_colors = shuffle(@color_keys);
    my $_fill   = $shuf_colors[0];
    #my $_stroke = $shuf_colors[1];
    my $_shape_w = rand_range($min_shape_w, $max_shape_w);

    my $style = SvgStyle->new(
	fill       => $PALETTE{$_fill},
	stroke     => $PALETTE{$_fill},
	stroke_w   => $stroke_w,
	color_mode => "rgba");

    my $c = Circle->new(
	id => "circle",
	center => Vec2->new(
	    x => rand_range($min_x, $max_x),
	    y => rand_range($min_y, $max_y)
	),
	radius => rand_range($min_shape_w, $max_shape_w));
    $svg->w_circle($fh, $c, $style);
}

print " < Finalizing and closing SVGFile...\n";
$svg->finalize($fh);

close($fh) or die "[ ERR ] FileCloseError $!";

print " < Exit 0.\n"
#___
