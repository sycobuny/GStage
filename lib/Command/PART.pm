#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/PART.pm: handle PART commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::PART;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NEEDMOREPARAMS
    ERR_NOSUCHCHANNEL
    ERR_NOTONCHANNEL
);

our (%channel);
Class::self->readable_variables qw(channel);

method parse($arguments) {
    my ($c) = split(' ', $arguments);
    $channel{id $self} = $self->stripc($c);
}

method run {
    my ($server) = $self->server;
    my ($origin) = $self->origin;
    my ($channame) = $channel{id $self};
    my ($channel);

    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    unless ($channame) {
        $origin->numeric(ERR_NEEDMOREPARAMS);
        return;
    }

    $channel = $server->find_channel($channame);

    unless ($channel) {
        $origin->numeric(ERR_NOSUCHCHANNEL);
        return;
    }

    unless ($origin->is_on($channel)) {
        $origin->numeric(ERR_NOTONCHANNEL, $channame);
        return;
    }

    $channel->broadcast($origin->prefix("PART $channame"));
    $channel->delete_user($origin);
}

1;
