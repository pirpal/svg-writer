svg-writer
----------

Work in progress, playing with [Perl 5.36](https://perldoc.perl.org/)

(Perl is cool again, give it a try!)


| file                 | descr                                                              |
|----------------------|--------------------------------------------------------------------|
| *main.pl*            | demo; run `$ perl main.pl`                                         |
| *demo_chessboard.pl* | demo; run `$ perl demo_chessboard.pl`                              |
|                      |                                                                    |
| *SvgWriter.pm*       | package: `SvgFile`                                                 |
|                      | - container for all drawings functions                             |
|                      | - defines path of output SVG file                                  |
|                      |                                                                    |
| *SvgGeometry.pm*     | packages:                                                          |
|                      | `SvgObject`, `SvgGroup`,                                           |
|                      | `Vec2`, `Vec3`                                                     |
|                      | `Line`, `Rect`, `Triangle`,                                        |
|                      | `Circle` `RegPolygon`                                              |
|                      | `Ellipse`                                                          |
|                      |                                                                    |
| *SvgColors.pm*       | class: `SvgStyle`:                                                 |
|                      | defines SVG properties `fill` `stroke`                             |
|                      | and `stroke-widh`                                                  |
|                      | Function `color_str(color, format)` accepts "hex", "rgb" or "rgba" |
|                      | as arguments and return either "#ff8000", "rgb(255,128,0)"         |
|                      | or "rgba(255,128,0,1.0)"                                           |
|                      |                                                                    |


### Usage

See *demo_chessboard.pl* and *main.pl* for examples

Here is a startup:

``` perl
use v5.36;

use lib '.' # if .pm files in the same directory
use SvgGeometry;
use SvgWriter;

# define some colors in a Hash:
our %PALETTE = (
  WHITE => 0xffffffff,
  BLACK => 0x000000ff,
  RED   => 0xf02020ff,
);

# define SVG dimensions:
my $width = 400;
my $height = 300;

# create a new SvgFile
my $svg = SvgFile->new(
   path => "out.svg",
   width => $width,
   height => $height,
   bg_color => $PALETTE{WHITE}
   );

# call SvgFile-> init to write headers
# to output file:
$svg->init; 

# define a shape:
my $circle = Circle->new(
	center => Vec2->new(x => $width / 2,
		                y => $height / 2),
	radius => $width / 3);

# and an associated SvgStyle:
my $style = SvgStyle->new(
   fill     => $PALETTE{RED},
   stroke   => $PALETTE{BLACK},
   stroke_w => 1.0
   );

# open output file to draw your shapes:
open(my $fh, ">>", $svg->path) or die "Could not open file: $!";

$svg->w_circle($fh, $circle, $style); 

# close file
close($fh) or die "Could not close file: $!";
```




