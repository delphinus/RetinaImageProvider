package RetinaImageProvider;
use common::sense;
use parent qw/Amon2/;
use Path::Class;
our $VERSION='0.01';
use 5.008001;

__PACKAGE__->load_plugin(qw/DBI/);

# initialize database
use DBI;
sub setup_schema {
    my $self = shift;
    my $dbh = $self->dbh();
    my $driver_name = $dbh->{Driver}->{Name};
    my $source = file(lc("sql/${driver_name}.sql"))->slurp('<:encoding(utf8)');
    for my $stmt (split /;/, $source) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr();
    }
}

sub imgpath { my ( $self ) = @_; #{{{
    return dir($self->config->{IMGPATH});
} #}}}

1;
