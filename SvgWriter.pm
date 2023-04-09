#!/usr/bin/perl

package SvgWriter;
use v5.36;
use Exporter 'import';
our @EXPORT_OK = qw(SvgFile);

#---------------------------------------
our $XML_VERSION  = "1.0";
our $SVG_VERSION  = "1.1";
our $BASE_PROFILE = "full";
our $XMLNS_SVG    = "http://www.w3.org/2000/svg";
our $XMLNS_XLINK  = "http://www.w3.org/1999/xlink";
our $XMLNS_EVENT  = "http://www.w3.org/2001/xml-events";


#---------------------------------------
package SvgFile;
use Moose;
use SvgColors qw(color_str);

has 'path', (is => 'ro', isa => 'Str');
has 'width', (is => 'ro', isa => 'Int');
has 'height', (is => 'ro', isa => 'Int');
has 'bg_color', (is => 'ro', isa => 'Int', required => 0);


sub w_style($self, $fh, $style) {
    if ($style->fill) {
	my $fill_str = color_str($style->fill, $style->color_mode);
	print $fh "fill=\"$fill_str\" ";
    }
    my $stroke_str = color_str($style->stroke, $style->color_mode);
    print $fh "stroke=\"$stroke_str\" ";
    print $fh "stroke-width=\"", $style->stroke_w, "\" ";
}


sub w_close_markup($self, $fh) {
    print $fh " />\n"
}

sub init($self) {
    open(my $fh, ">", $self->path) or die "[ERR] failed to open svg: $!";
    # XML markup:
    print $fh "<?xml version=\"$XML_VERSION\" ";
    print $fh "encoding=\"UTF-8\" standalone=\"no\"?>\n";
    # SVG header:
    print $fh "<svg\n";
    print $fh "  width=\"", $self->width, "\"\n";
    print $fh "  height=\"", $self->height, "\"\n";
    print $fh "  version=\"$SVG_VERSION\"\n";
    print $fh "  xmlns=\"$XMLNS_SVG\"\n";
    print $fh "  xmlns:xlink=\"$XMLNS_XLINK\"\n";
    print $fh "  xmlns:ev=\"$XMLNS_EVENT\">\n";
    # Background rect:
    if ($self->bg_color) {
	print $fh "  <rect x=\"0\" y=\"0\" width=\"", $self->width, "\" ";
	print $fh "height=\"", $self->height, "\" ";
	my $fill_str = color_str($self->bg_color, "hex");
	print $fh "fill=\"$fill_str\" />\n";
    }
    close $fh or die "[ERR] failed to close file: $!";
}


sub w_line($self, $fh, $line, $style) {
    print $fh "  <line ";
    $line->print_id($fh);
    print $fh "x1=\"", $line->v1->x, "\" ";
    print $fh "y1=\"", $line->v1->y, "\" ";
    print $fh "x2=\"", $line->v2->x, "\" ";
    print $fh "y2=\"", $line->v2->y, "\" ";
    $self->w_style($fh, $style);
    $self->w_close_markup($fh);
}



sub w_rect($self, $fh, $rect, $style) {
    print $fh "  <rect ";
    $rect->print_id($fh);
    print $fh "x=\"", $rect->origin->x, "\" ";
    print $fh "y=\"", $rect->origin->y, "\" ";
    print $fh "width=\"", $rect->width, "\" ";
    print $fh "height=\"", $rect->height, "\" ";
    if ($rect->round) {
	print $fh "rx=\"", $rect->round->x, "\" ";
	print $fh "ry=\"", $rect->round->y, "\" ";
    }
    $self->w_style($fh, $style);
    $self->w_close_markup($fh);
}


sub w_circle($self, $fh, $c, $style) {
    my $cx = $c->center->x;
    my $cy = $c->center->y;
    my $r = $c->radius;
    print $fh "  <circle ";
    $c->print_id($fh);
    print $fh " cx=\"$cx\" cy=\"$cy\" r=\"$r\" "; 
    $self->w_style($fh, $style);
    $self->w_close_markup($fh);
}

sub w_triangle($self, $fh, $t, $style) {
    print $fh "  <g ";
    $t->print_id($fh);
    my $ab = Line->new(
	v1 => $t->a,
	v2 => $t->b);
    print $fh "  ";
    $self->w_line($fh, $ab, $style);
    my $bc = Line->new(
        v1 => $t->b,
        v2 => $t->c);
    print $fh "  ";
    $self->w_line($fh, $bc, $style);
    my $ac = Line->new(
        v1 => $t->a,
        v2 => $t->c);
    print $fh "  ";
    $self->w_line($fh, $ac, $style);
   
}

sub w_reg_polygon($self, $fh, $rp, $line_style) {
    # $FH         file handler
    # $RP         RegPolygon
    # $LINE_STYLE SvgStyle
    my @vertices = $rp->build_vecs;
    my $max_index = $rp->sides - 1;
    my $x1 = 0.0;
    my $y1 = 0.0;
    my $x2 = 0.0;
    my $y2 = 0.0;
    foreach (0..$max_index) {
	if ($_ == 0) {
	    $x1 = int($vertices[$_]->x + 0.5);         # [0].x
	    $y1 = int($vertices[$_]->y + 0.5);         # [0].y
	    $x2 = int($vertices[$max_index]->x + 0.5); # [last].x
	    $y2 = int($vertices[$max_index]->y + 0.5); # [last].y
	} else {
            $x1 = int($vertices[$_]->x + 0.5);   # [$_].x 
            $y1 = int($vertices[$_]->y + 0.5);   # [$_].y
            $x2 = int($vertices[$_-1]->x + 0.5); # [$_ - 1].x
            $y2 = int($vertices[$_-1]->y + 0.5); # [$_ - 1].y
	}
	print $fh "  <line ";
	$rp->print_id($fh);
	print $fh " x1=\"", $x1, "\" ";
	print $fh "y1=\"", $y1, "\" ";
	print $fh "x2=\"", $x2, "\" ";
	print $fh "y2=\"", $y2, "\" ";
	$self->w_style($fh, $line_style);
	$self->w_close_markup($fh);
    }
}



#sub w_polygon($self, $fh, $id, @points, $style) {
#    print $fh "  <polygon ";
#    if ($id) {
#	print $fh "id=\"", $id, "\" ";
#    }
#    print $fh ("points =\"");
#    foreach (@points) {
#	print $fh int($_->x + 0.5), ",", int($_->y + 0.5), " ";
#    }
#    print $fh "\" "; # close points quotes
#    $self->w_style($fh, $style);
#    $self->w_close_markup($fh);
#}

sub finalize($self, $fh) {
    print $fh "</svg>\n";
}

no Moose;
__PACKAGE__->meta->make_immutable;

#____
1;

