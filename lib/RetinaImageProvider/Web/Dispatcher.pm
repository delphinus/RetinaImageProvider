package RetinaImageProvider::Web::Dispatcher;
use common::sense;
use Amon2::Web::Dispatcher::Lite;
use RetinaImageProvider;

use Log::Minimal;
use Path::Class;

my $app = RetinaImageProvider->new;

any '/' => sub {
    my ($c) = @_;
    $c->render('index.tt');
};

get '/get/{img:.*}' => sub { my ( $c, $args ) = @_; #{{{
    my $img = $app->imgpath->file($args->{img});
    my ($ext) = $img =~ /\.([^.]+)$/;
    if (defined $ext and -f $img) {
        my $content;
        eval { $content = $img->slurp; };
        if (!$@ and defined $content and $content ne '') {
            return $c->create_response(
                200,
                [
                    'Content-Type' => 'img/' . lc($ext),
                    'Content-Length' => -s $img,
                ],
                [$content],
            );
        }
    }
    $c->res_404;
}; #}}}

1;
