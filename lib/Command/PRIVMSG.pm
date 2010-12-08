#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/PRIVMSG.pm: handle PRIVMSG commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::PRIVMSG;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%target, %message);
Class::self->readable_variables qw(target message);

my ($re) = qr/^([^ ]*) *:?(.*)/;

method parse($arguments) {
    my ($t, $m) = $arguments =~ $re;

    $target{id $self} = $t;
    $message{id $self} = $m;
}

method run {
    print "running a PRIVMSG to @{[$self->target]}: @{[$self->message]}\n";
}

1;
