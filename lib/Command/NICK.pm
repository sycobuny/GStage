package Command::NICK;
@{__PACKAGE__.'::ISA'} = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%nickname);
__PACKAGE__->variables(\%nickname);
__PACKAGE__->readers('nickname');

method parse($arguments) {
    my ($n) = split(' ', $arguments);
    $nickname{id $self} = $self->stripc($n);
}

method run {
    print "running a NICK change into @{[$self->nickname]}\n";
}

1;
