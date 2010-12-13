#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/KICK.pm: handle KICK commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::KICK;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NEEDMOREPARAMS
    ERR_NOSUCHNICK
    ERR_NOSUCHCHANNEL
    ERR_BADCHANMASK
    ERR_CHANOPRIVSNEEDED
    ERR_NOTONCHANNEL
    ERR_USERNOTINCHANNEL
);

our (%channel, %target, %message);
Class::self->readable_variables qw(channel target message);

my ($re) = qr/^([^ ]*) *([^ ]*) *:?(.*)$/;

method parse($arguments) {
    my ($c, $t, $m) = $arguments =~ $re;

    $channel{id $self} = $c;
    $target{id $self} = $t;
    $message{id $self} = $m;
}

method run {
    my ($server) = $self->server;
    my ($origin) = $self->origin;
    my ($channame) = $channel{id $self};
    my ($nickname) = $target{id $self};
    my ($message) = $message{id $self} || '';
    my ($channel, $user);

    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    unless ($channame and $nickname) {
        $origin->numeric(ERR_NEEDMOREPARAMS, 'KICK');
        return;
    }

    $channel = $server->find_channel($channame);
    unless ($channel) {
        $origin->numeric(ERR_NOSUCHCHANNEL, $channame);
        return;
    }

    $user = $server->find_user($nickname);
    unless ($user) {
        $origin->numeric(ERR_NOSUCHNICK, $nickname);
        return;
    }

    unless ($origin->is_on($channel) or $origin->is_supervisor) {
        $origin->numeric(ERR_NOTONCHANNEL, $channame);
        return;
    }

    unless ($origin->is_op($channel) or $origin->is_supervisor) {
        $origin->numeric(ERR_CHANOPRIVSNEEDED, $channame);
        return;
    }

    unless ($user->is_on($channel)) {
        $origin->numeric(ERR_USERNOTINCHANNEL, $nickname, $channame);
        return;
    }

    $channel->broadcast($origin->prefix("KICK $channame $nickname :$message"));
    $channel->delete_user($user);
    $channel->add_bozo($user);
}

1;
