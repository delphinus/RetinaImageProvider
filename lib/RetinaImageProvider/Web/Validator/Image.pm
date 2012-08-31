package RetinaImageProvider::Web::Validator::Image;
use common::sense;
use parent qw!RetinaImageProvider::Web::Validator!;
use Path::Class;

sub get_img { my ( $self, $c, $args ) = @_; #{{{
    my $width = $c->req->param('w');
    my $height = $c->req->param('h');

    if (defined $width && $width =~ /^\d+$/) {
        $c->set_invalid_form(width => 'TOO_LARGE')
            if $width > 10000;
    } else {
        $c->set_invalid_form(width => 'NO_WIDTH');
    }

    if (defined $height && $height =~ /^\d+$/) {
        $c->set_invalid_form(height => 'TOO_LARGE')
            if $height > 10000;
    } else {
        $c->set_invalid_form(height => 'NO_HEIGHT');
    }

    my $dir = dir($c->config->{IMGPATH});
    my $img = $args->{img};

    unless (defined $img && 255 >= length $img) {
        $c->set_invalid_form(img => 'TOO_LONG');
    }

    if (!defined $img || 0 == length $img) {
        $c->set_invalid_form(img => 'NO_IMG');
    } elsif ($img !~ /\.(jpe?g|png|bmp)$/) {
        $c->set_invalid_form(img => 'CANNOT_DETECT');
    } elsif (!-f $dir->file($img)) {
        $c->set_invalid_form(img => 'NOT_EXIST');
    }
} #}}}

1;
