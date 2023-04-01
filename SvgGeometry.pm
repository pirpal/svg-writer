#!/usr/bin/perl

package SvgGeometry;
use v5.36;
use Exporter 'import';
our @EXPORT_OK = qw(Circle Ellipse Line Rect);

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

#----------------------------------------
package Circle;
use Moose;

has 'center' => (is => 'ro', isa => 'Vec2');
has 'radius' => (is => 'ro', isa => 'Num');

#---------------------------------------
package Ellipse;
use Moose;

has 'center' => (is => 'ro', isa => 'Vec2');
has 'round'  => (is => 'ro', isa => 'Vec2');

#----------------------------------------
package Line;
use Moose;

has 'v1' => (is => 'ro', isa => 'Vec2');
has 'v2' => (is => 'ro', isa => 'Vec2');

#---------------------------------------
package Rect;
use Moose;

has 'origin' => (is => 'ro', isa => 'Vec2');
has 'width'  => (is => 'ro', isa => 'Num');
has 'height' => (is => 'ro', isa => 'Num');
has 'round'  => (is => 'ro', isa => 'Vec2', required => 0);


#___
1;
