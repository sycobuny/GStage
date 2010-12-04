package Command::PART;
@{__PACKAGE__.'::ISA'} = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%channel);
__PACKAGE__->variables(\%channel);
__PACKAGE__->readers('channel');

method parse($arguments) {
    my ($c) = split(' ', $arguments);
    $channel{id $self} = $self->stripc($c);
}

method run {
    print "running a PART from @{[$self->channel]}\n";
}

1;
