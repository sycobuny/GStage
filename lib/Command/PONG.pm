package Command::PONG;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%parameter);
Class::self->readable_variables qw(parameter);

method parse($arguments) {
    $parameter{id $self} = $self->stripc($arguments);
}

method run {
    print "running a PONG replying to @{[$self->parameter]}\n";
}

1;
