package RetinaImageProvider::Logic::Image;
use common::sense;
use parent qw!RetinaImageProvider::Logic!;
use Image::Magick;
use Path::Class;

__PACKAGE__->mk_accessors(qw!
    width height img
!);

sub new { my $class = shift; #{{{
    my $args = ref $_[0] ? $_[0] : +{@_};

    return $class->SUPER::new($args);
} #}}}

sub get { my $self = shift; #{{{
    my $data = $self->get_from_db || +{};
    $data = $self->get_from_file unless $data->{content};

    my ($ext) = $self->img =~ /\.([^.]+)$/;
    $ext = lc $ext;

    if ($data->{content}) {
        $data->{content_type} = "image/$ext";
        $data->{result} = 'success';
    }

    return $data;
} #}}}

sub get_from_db { my $self = shift; #{{{
    my %data;

    eval {
        $self->ds->select('images',
            [qw!
                content
                LENGTH(content)
            !],
            +{
                filename => $self->img,
                width => $self->width,
                height => $self->height,
            },
        )->into(@data{qw!content content_length!});
    };
    if ($@ || !$data{content} || !$data{content_length}) {
        $data{content} = '';
    }

    return \%data;
} #}}}

sub get_from_file { my $self = shift; #{{{

    my ($ext) = $self->img =~ /\.([^.]+)$/;
    $ext = lc $ext;
    my $img = dir($self->config->{IMGPATH})->file($self->img);

    my $im = Image::Magick->new(magick => $ext);
    my $content;
    eval {
        $im->Read($img);
        $im->Resize(geometry => $self->width . 'x' . $self->height);
        ($content) = $im->ImageToBlob;
    };
    if (!$@ && $content) {
        $self->save_db($content);
        return $self->get_from_db;
    }
} #}}}

sub save_db { my ( $self, $content ) = @_; #{{{
    eval {
=pod
        $self->ds->insert('images', +{
            filename => $self->img,
            width => $self->width,
            height => $self->height,
            content => $content,
            timestamp => time,
        });
=cut
        my $sth = $self->dbh->prepare(<<SQL);
            INSERT INTO images VALUES (?, ?, ?, ?, ?);
SQL
        use DBI qw!:sql_types!;
        $sth->bind_param(1, $self->img, SQL_VARCHAR);
        $sth->bind_param(2, $self->width, SQL_VARCHAR);
        $sth->bind_param(3, $self->height, SQL_VARCHAR);
        $sth->bind_param(4, $content, SQL_BLOB);
        $sth->bind_param(5, time, SQL_VARCHAR);
        $sth->execute;
    };
} #}}}

1;
