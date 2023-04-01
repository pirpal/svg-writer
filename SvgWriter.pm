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
    open(my $fh, ">>", $self->path) or die "[ERR] failed to open svg: $!";
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
    print $fh "  <line x1=\"", line->v1->x, "\" ";
    print $fh "y1=\"", line->v1->y, "\" ";
    print $fh "x2=\"", line->v2->x, "\" ";
    print $fh "y2=\"", line->v2->y, "\" ";
    $self->w_style($fh, $style);
    $self->w_close_markup($fh);
}


sub w_rect($self, $fh, $rect, $style) {
    print $fh "  <rect x=\"", $rect->origin->x, "\" ";
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
    print $fh "  <circle cx=\"$cx\" cy=\"$cy\" r=\"$r\" "; 
    $self->w_style($fh, $style);
    $self->w_close_markup($fh);
}

sub finalize($self, $fh) {
    print $fh "</svg>\n";
}

#____
1;

