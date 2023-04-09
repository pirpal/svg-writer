#!/usr/bin/perl

#; SvgGeometry.pm [
package SvgGeometry;
use v5.36;
use Exporter 'import';
our @EXPORT_OK = qw(Circle Ellipse Line Rect RegPolygon);

our $PI = 3.14159265359; 


use constant {
    _triangle => 3,
    _square   => 4,
    _pentagon => 5,
    _hexagon  => 6,
    _heptagon => 7,
    _octogon  => 8,
    _max_reg_polyg => 64
};

#;   - SvgObject
package SvgObject;
use Moose;
# Base class for ids

has 'id', (is => 'ro', 'isa' => 'Str', required => 0);

sub print_id($self, $fh) {
    if ($self->id) {
	print $fh "id=\"", $self->id, "\" ";
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

#;   - SvgGroup
package SvgGroup;
use Moose;
extends 'SvgObject';


has 'style', (is => 'ro',
	      isa => 'SvgStyle',
	      required => 0);

no Moose;
__PACKAGE__->meta->make_immutable;
                                         
#;   - Vec2
package Vec2;
use Moose;
extends 'SvgObject';

has 'x' => (is => 'rw', isa => 'Num', writer => 'set_x');
has 'y' => (is => 'rw', isa => 'Num', writer => 'set_y');

#sub set_x($self, $new_x) {
#    $self->x = $new_x;
#}
#
#sub set_y($self, $new_y) {
#    $self->y = $new_y;
#}

sub log($self) {
    my $p = \$self;
    print "[ Vec2 $p '", $self->id, "' ] ";
    print "x: ", int($self->x + 0.5);
    print ", y: ", int($self->y + 0.5), "\n";
}

no Moose;
__PACKAGE__->meta->make_immutable;


#;   - Vec3
package Vec3;
use Moose;

extends 'Vec2';

has 'z' => (is => 'rw', isa => 'Num', writer => 'set_z');

#sub set_z($self, $new_z) {
#    $self->z = $new_z;
#}

sub log($self) {
    my $p = \$self;
    print "[ Vec3 $p ";
    if ($self->id) {
	print "id=\"", $self->id, "\" ";
    } 
    print " x: ", int($self->x + 0.5);
    print ", y: ", int($self->y + 0.5);
    print ", z: ", int($self->y + 0.5), "]\n";
}

no Moose;
__PACKAGE__->meta->make_immutable;


#;   - Circle
package Circle;
use Moose;
extends 'SvgObject';

has 'center' => (is => 'rw', isa => 'Vec2');
has 'radius' => (is => 'rw', isa => 'Num');

no Moose;
__PACKAGE__->meta->make_immutable;


#;  - Ellipse
package Ellipse;
use Moose;
extends 'SvgObject';

has 'center' => (is => 'rw', isa => 'Vec2');
has 'round'  => (is => 'rw', isa => 'Vec2');

no Moose;
__PACKAGE__->meta->make_immutable;


#;  - Line
package Line;
use Moose;
extends 'SvgObject';

has 'v1' => (is => 'rw', isa => 'Vec2');
has 'v2' => (is => 'rw', isa => 'Vec2');

no Moose;
__PACKAGE__->meta->make_immutable;


#;  - Triangle
package Triangle;
use Moose;
extends 'SvgObject';

has 'a' => (is => 'rw', isa => 'Vec2');
has 'b' => (is => 'rw', isa => 'Vec2');
has 'c' => (is => 'rw', isa => 'Vec2');

no Moose;
__PACKAGE__->meta->make_immutable;


#;  - Rect
package Rect;
use Moose;
extends 'SvgObject';

has 'origin' => (is => 'rw', isa => 'Vec2');
has 'width'  => (is => 'rw', isa => 'Num');
has 'height' => (is => 'rw', isa => 'Num');
has 'round'  => (is => 'rw', isa => 'Vec2', required => 0);


no Moose;
__PACKAGE__->meta->make_immutable;


#;  - RegPolygon
package RegPolygon;
use Moose;
use Vec3;

# RegPolygon is for all regular shapes based on
# the circle, depending on attribute SIDES, from
# 3 up to 64:
# 3 Isocele Triangle  6 Hexagon   9 ... etc
# 4 Square            7 Heptagon
# 5 Pentagon          8 Octogon

extends 'Circle';

has 'sides', (is => 'rw',  isa => 'Num');
has 'flat',  (is => 'rw', isa => 'Bool');

sub build_vecs($self) {
    # build_vecs -> RegPolygon -> (Vec3)
    # Every polygon is build first in 2d,
    # with z set to 0.0, for projection on SVG 2d space
    my @vecs = ();
    my $a_deg = 0.0;
    my $a_rad = 0.0;
    my $polyg_angle = 360.0 / $self->sides;
    my $rotation = 0;
    if (!$self->flat) {
	$rotation = $polyg_angle / 2;
    }
    foreach (0..$self->sides-1) {
	$a_deg = $polyg_angle * $_ + $rotation;
	$a_rad = $PI / 180 * $a_deg;
	my $x = $self->center->x + $self->radius * cos($a_rad);
	my $y = $self->center->y + $self->radius * sin($a_rad);
	#print "debug x: $x, y: $y\n";
	my $v = Vec3->new(
	    x => $x,
	    y => $y,
	    z => 0.0);
	push(@vecs, ($v));
    }
    return @vecs;
}

no Moose;
__PACKAGE__->meta->make_immutable;



#;  - Star
package Star;
use Moose;
extends 'SvgObject';

has 'center',     (is => 'rw', isa => 'Vec2');
has 'branches',   (is => 'rw', isa => 'Num');
has 'in_radius',  (is => 'rw', isa => 'Num');
has 'out_radius', (is => 'rw', isa => 'Num');


no Moose;
__PACKAGE__->meta->make_immutable;

#;]
1;
