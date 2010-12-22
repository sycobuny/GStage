#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/LIST.pm: handle LIST commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::LIST;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NOSUCHSERVER
    RPL_LISTSTART
    RPL_LIST
    RPL_LISTEND
);

method run {
    my ($server) = $self->server;
    my ($origin) = $self->origin;

    $origin->numeric(RPL_LISTSTART);

    foreach my $channel ($server->channels) {
        my ($name, $users, $topic);
        next if ($channel->secret and !$origin->is_supervisor);

        $name = $channel->name;
        $users = scalar($channel->users);
        $topic = $channel->topic || '';

        $origin->numeric(RPL_LIST, $name, $users, $topic);
    }

    $origin->numeric(RPL_LISTEND);
}

1;