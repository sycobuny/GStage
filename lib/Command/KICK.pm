package Command::KICK;
@{__PACKAGE__.'::ISA'} = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%channel, %target, %message);
__PACKAGE__->variables(\(%channel, %target, %message));
__PACKAGE__->readers( qw(channel target message) );

my ($re) = qr/^([^ ]*) *([^ ]*) *:?(.*)$/;

method parse($arguments) {
    my ($c, $t, $m) = $arguments =~ $re;

    $channel{id $self} = $c;
    $target{id $self} = $t;
    $message{id $self} = $m;
}

method run {
    print "running a KICK of @{[$self->target]} from @{[$self->channel]} " .
          "for: @{[$self->message]}\n";
}

1;