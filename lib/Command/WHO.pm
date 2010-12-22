#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/WHO.pm: handle WHO commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::WHO;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NOSUCHSERVER
    ERR_NOSUCHCHANNEL
    RPL_WHOREPLY
    RPL_ENDOFWHO
);

our (%target);
Class::self->readable_variables qw(target);

method parse($arguments) {
    $target{id $self} = $self->stripc($arguments || '');
}

method run {
    local ($_);
    my ($server) = $self->server;
    my ($origin) = $self->origin;
    my ($target) = $target{id $self};
    my ($channel, @users);

    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    if (!$target or ($target eq '0')) {
        return unless ($origin->is_supervisor);
        @users = $server->users;
    } else {
        unless ($channel = $server->find_channel($target)) {
            $origin->numeric(ERR_NOSUCHCHANNEL, $target);
            return;
        } else {
            @users = $channel->users;
        }
    }

    foreach my $user (@users) {
        $origin->numeric(RPL_WHOREPLY, $target, $user->username, $user->mask,
                         $server->name, $user->nickname, $user->realname);
    }

    $origin->numeric(RPL_ENDOFWHO, $target);
}

1;