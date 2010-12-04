package Command::NICK;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%nickname);
Class::self->readable_variables qw(nickname);

method parse($arguments) {
    my ($n) = split(' ', $arguments);
    $nickname{id $self} = $self->stripc($n);
}

method run {
    print "running a NICK change into @{[$self->nickname]}\n";
}

1;
