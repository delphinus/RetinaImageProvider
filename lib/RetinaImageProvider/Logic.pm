package RetinaImageProvider::Logic;
use common::sense;
use parent qw!RetinaImageProvider Class::Accessor::Fast!;
use Log::Minimal;
use Path::Class;

sub log { my ($self, $str) = @_; #{{{
    my ($package, $filename, $line) = caller;
    my $file = file($self->config->{LOG});
    -d $file->parent or $file->parent->mkpath;
    local $Log::Minimal::AUTODUMP = 1;
    local $Log::Minimal::PRINT = sub {
        my ( $time, $type, $message, $trace,$raw_message) = @_;
        my $fh = $file->open('a') or return;
        $fh->print("$time [$package](line: $line) $message\n");
    };
    infof($str);
} #}}}

1;
