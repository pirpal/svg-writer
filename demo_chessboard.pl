#!/usr/bin/perl

use v5.36;

use lib '.';
use SvgWriter;
use SvgGeometry;


sub chessboard($path, $light, $dark, $sq_w) {
    # $PATH string: SVG file path to write out
    #              (created if not exists)
    # $LIGHT int: hexadecimal 32-bit int as '0xFF0080FF'
    # $DARK  int: "
    # $SQ_W  int: square width in piwels. Final SVG size
    #             is: ($sq_w * 8) x ( $sq_w * 8)
    print " < creating SvgStyle 'dark'...\n";
    my $dark_style = SvgStyle->new(
        fill       => $dark,
        stroke     => $dark,
        stroke_w   => 1.0,
        color_mode => "hex"
        );
                                                                    
    my $w = int($sq_w * 8);
                                                                    
    print " < creating SvgFile $w x $w as '$path'\n";
    my $svg = SvgFile->new(
        path     => $path,
        width    => $w,
        height   => $w,
        bg_color => $light
        );
    $svg->init;
                                                                    
    my $square = Rect->new(
        origin => Vec2->new(x => 0.0, y => 0.0),
        width  => $sq_w,
        height => $sq_w
        );

    print " < writing squares...\n";
    open(my $fh, ">>", $svg->path) or die "Could not open file: $!";

    foreach my $row (0..7) {
        foreach my $col (0..7) {
            $square->origin->set_x($col * $sq_w);
            $square->origin->set_y($row * $sq_w);
	    my $a = ($row % 2 != 0 && $col % 2 == 0);
	    my $b = ($row % 2 == 0 && $col % 2 != 0);
            if ($a || $b) {
                $svg->w_rect($fh, $square, $dark_style);
            }
        }
    }

    $svg->finalize($fh);
    
    print " < closing file ...\n";
    close($fh) or die "Could not close file: $!";
    print " < exiting with code 0 :)!\n";
}



# ---- DEMO CHESSBOARD ----
our %COLORS = (
    _DARK  => 0x521800ff, # #521800
    _LIGHT => 0xff9466ff  # #ff9466
);

chessboard("demo_chessboard.svg",
	   $COLORS{_LIGHT},
	   $COLORS{_DARK},
	   32);

# end.
