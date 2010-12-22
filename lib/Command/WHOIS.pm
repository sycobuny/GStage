#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/WHOIS.pm: handle WHOIS commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::WHOIS;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NOSUCHSERVER
    ERR_NONICKNAMEGIVEN
    ERR_NOSUCHNICK
    RPL_WHOISUSER
    RPL_WHOISCHANNELS
    RPL_WHOISSERVER
    RPL_AWAY
    RPL_WHOISOPERATOR
    RPL_WHOISIDLE
    RPL_ENDOFWHOIS
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
    my ($user, @channels);

    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    unless ($target) {
        $origin->numeric(ERR_NONICKNAMEGIVEN);
        return;
    }

    unless ($user = $server->find_user($target)) {
        $origin->numeric(ERR_NOSUCHNICK, $target);
        return;
    }

    @channels = map { $_->name } ($user->channels);

    $origin->numeric(RPL_WHOISUSER, $user->nickname, $user->username,
                     $user->mask, $user->realname);
    $origin->numeric(RPL_WHOISCHANNELS, $user->nickname, join(' ', @channels));
    $origin->numeric(RPL_WHOISSERVER, $user->nickname, $user->server->name,
                     $user->server->name);
    # RPL_AWAY
    # RPL_WHOISOPERATOR
    $origin->numeric(RPL_WHOISIDLE, $user->nickname, 0); # XXX fix idle time
    $origin->numeric(RPL_ENDOFWHOIS, $user->nickname);
}

1;