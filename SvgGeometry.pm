#!/usr/bin/perl

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


#----------------------------------------
package Vec2;
use Moose;

has 'x' => (is => 'ro', isa => 'Num');
has 'y' => (is => 'ro', isa => 'Num');



#----------------------------------------
package Vec3;
use Moose;
extends 'Vec2';

has 'z' => (is => 'ro', isa => 'Num');

sub log($self) {
    my $p = \$self;
    print "[ Vec3 $p ] x: ", int($self->x + 0.5);
    print ", y: ", int($self->y + 0.5);
    print ", z: ", int($self->y + 0.5), "\n";
}

no Moose;
__PACKAGE__->meta->make_immutable;


#----------------------------------------
package Circle;
use Moose;

has 'center' => (is => 'ro', isa => 'Vec2');
has 'radius' => (is => 'ro', isa => 'Num');

no Moose;
__PACKAGE__->meta->make_immutable;


#---------------------------------------
package Ellipse;
use Moose;

has 'center' => (is => 'ro', isa => 'Vec2');
has 'round'  => (is => 'ro', isa => 'Vec2');

no Moose;
__PACKAGE__->meta->make_immutable;


#----------------------------------------
package Line;
use Moose;

has 'v1' => (is => 'ro', isa => 'Vec2');
has 'v2' => (is => 'ro', isa => 'Vec2');

no Moose;
__PACKAGE__->meta->make_immutable;


#---------------------------------------
package Triangle;
use Moose;
has 'a' => (is => 'ro', isa => 'Vec2');
has 'b' => (is => 'ro', isa => 'Vec2');
has 'c' => (is => 'ro', isa => 'Vec2');

no Moose;
__PACKAGE__->meta->make_immutable;


#---------------------------------------
package Rect;
use Moose;

has 'origin' => (is => 'ro', isa => 'Vec2');
has 'width'  => (is => 'ro', isa => 'Num');
has 'height' => (is => 'ro', isa => 'Num');
has 'round'  => (is => 'ro', isa => 'Vec2', required => 0);


no Moose;
__PACKAGE__->meta->make_immutable;


#---------------------------------------
package RegPolygon;
use Moose;
use Vec3;
extends 'Circle'; # Vec2 $center, Num $radius


has 'tag',   (is => 'ro',  isa => 'Str');
has 'sides', (is => 'ro',  isa => 'Num');
has 'flat',  (is => 'ro', isa => 'Bool');


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

#___
1;
