package Command::QUIT;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%message);
__PACKAGE__->variables(\%message);
__PACKAGE__->readers('message');

method parse($arguments) {
    $message{id $self} = $self->stripc($arguments);
}

method run {
    print "running a QUIT for @{[$self->message]}\n";
}

1;
