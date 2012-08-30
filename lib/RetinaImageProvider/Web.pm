package RetinaImageProvider::Web;
use common::sense;
use parent qw/RetinaImageProvider Amon2::Web/;
use Path::Class;

# dispatcher
use RetinaImageProvider::Web::Dispatcher;
sub dispatch {
    return (RetinaImageProvider::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# setup view class
use Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [
            dir(__PACKAGE__->base_dir)->subdir('tmpl')->stringify
        ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::Star' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            static_file => do {
                my %static_file_cache;
                sub {
                    my $fname = shift;
                    my $c = Amon2->context;
                    if (not exists $static_file_cache{$fname}) {
                        my $mtime =
                            dir($c->base_dir)->file($fname)->stat->mtime;
                        $static_file_cache{$fname} = $mtime;
                    }
                    return $c->uri_for($fname, +{
                        t => $static_file_cache{$fname} || 0,
                    });
                }
            },
        },
        %$view_conf
    });
    sub create_view { $view }
}


# load plugins
__PACKAGE__->load_plugins(
    #'Web::FillInFormLite',
    #'Web::CSRFDefender',
);

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

# setup validator
use FormValidator::Simple;
use Module::Load;
use YAML;
VALIDATOR: {
    my $setting = __PACKAGE__->config->{validator};
    last VALIDATOR unless defined $setting;

    if (exists $setting->{profiles}) {
        my $data = ref $setting->{profiles} ? $setting->{profiles}
            : YAML::LoadFile($setting->{profiles});
        __PACKAGE__->config->{validator}{__profile_data} = $data;
    }

    my $plugins = exists $setting->{plugins}
        ? $setting->{plugins} : [];
    FormValidator::Simple->import(@$plugins);

    FormValidator::Simple->set_messages($setting->{messages})
        if exists $setting->{messages};
    FormValidator::Simple->set_option(%{$setting->{options}})
        if exists $setting->{options};
    FormValidator::Simple->set_message_format($setting->{message_format})
        if exists $setting->{message_format};
    FormValidator::Simple
        ->set_message_decode_from($setting->{message_decode_from})
            if exists $setting->{message_decode_from};
}

sub form { my ( $c ) = shift; #{{{
    if ($_[0]) {
        my $form = $_[1] ? [@_] : $_[0];
        $c->{validator}->check($c->req, $form);
    }

    return $c->{validator}->results;
} #}}}

sub set_invalid_form { my ( $c ) = shift; #{{{
    local $Log::Minimal::AUTODUMP=1;
    $c->{validator}->set_invalid(@_);

    return $c->{validator}->results;
} #}}}

sub validate { my ( $c, $action, $args ) = @_; #{{{
    my $p = $c->config->{validator}{__profile_data};
    my $data = $p->{$action} // +{};
    $c->form($data->{auto});

    if (defined $data->{logic}) {
        my $module = __PACKAGE__ . "::Validator::$data->{logic}{module}";
        load $module;
        my $logic = $module->new;
        for my $method (@{$data->{logic}{methods}}) {
            $logic->$method($c, $args);
        }
    }

    return $c->{validator}->results;
} #}}}

sub error_page { my ( $c, $action, $tmpl ) = @_; #{{{
    $c->render($tmpl // $c->config->{error_page} // 'error.tt',
        +{result => $c->form, action => $action});
} #}}}

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;

        $c->{validator} = FormValidator::Simple->new;

        return;
    },
);

1;
