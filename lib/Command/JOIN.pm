package Command::JOIN;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%channels, %keys);
Class::self->private_variables qw(channels keys);

method initialize($server, $origin, $arguments) {
    $channels{id $self} = [];
    $keys{id $self} = [];

    $self->SUPER::initialize($server, $origin, $arguments);
}

method parse($arguments) {
    my ($c, $k) = split(' ', $arguments);

    @{ $channels{id $self} } = split(',', ($c || ''));
    @{ $keys{id $self} } = split(',', ($k || ''));
}

method run {
    print "running a JOIN to ";
    print join(', ', map {
        ($self->keys)[$_] ?
            "@{[($self->channels)[$_]]} using @{[($self->keys)[$_]]}" :
            ($self->channels)[$_]
    } (0 .. (scalar($self->channels) - 1)));
    print "\n";
}

method channels { @{ $channels{id $self} } }
method keys { @{ $keys{id $self} } }

1;
