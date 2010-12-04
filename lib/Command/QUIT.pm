package Command::QUIT;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%message);
Class::self->readable_variables qw(message);

method parse($arguments) {
    $message{id $self} = $self->stripc($arguments);
}

method run {
    print "running a QUIT for @{[$self->message]}\n";
}

1;
