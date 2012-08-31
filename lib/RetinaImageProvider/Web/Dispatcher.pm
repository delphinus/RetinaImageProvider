package RetinaImageProvider::Web::Dispatcher;
use common::sense;
use Amon2::Web::Dispatcher::Lite;
use RetinaImageProvider::Logic::Image;

use Path::Class;

get '/{img:.*}' => sub { my ( $c, $args ) = @_; #{{{
    my $action = 'get_img';
    $c->validate($action, $args);
    if ($c->form->has_error) {
        return $c->error_page($action);
    }

    my $p = $c->req->parameters;

    my $logic = RetinaImageProvider::Logic::Image->new(
        width => $p->{w},
        height => $p->{h},
        img => $args->{img},
    );

    my $data = $logic->get;

    if ($data->{result} eq 'success') {
        $c->create_response(
            200,
            [
                'Content-Type' => $data->{content_type},
                'Content-Length' => $data->{content_length},
            ],
            [$data->{content}],
        );
    } else {
        $c->res_404;
    }
}; #}}}

1;
