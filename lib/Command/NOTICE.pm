package Command::NOTICE;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%target, %message);
__PACKAGE__->variables(\(%target, %message));
__PACKAGE__->readers( qw(target message) );

my ($re) = qr/^([^\x20]*)\x20*:?(.*)/;

method parse($arguments) {
    my ($t, $m) = $arguments =~ $re;

    $target{id $self} = $t;
    $message{id $self} = $m;
}

method run {
    print "running a NOTICE to @{[$self->target]}: @{[$self->message]}\n";
}

1;
