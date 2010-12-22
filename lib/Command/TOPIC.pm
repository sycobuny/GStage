#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/WHO.pm: handle WHO commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::TOPIC;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NEEDMOREPARAMS
    ERR_NOSUCHCHANNEL
    ERR_NOTONCHANNEL
    ERR_CHANOPRIVSNEEDED
    RPL_NOTOPIC
    RPL_TOPIC
);

our (%channel, %topic);
Class::self->readable_variables qw(target);

method parse($arguments) {
    local ($1, $2);
    my ($channel, $topic);

    ($channel, $topic) = $arguments =~ /^(\S+)\s*(.*)$/;

    $channel{id $self} = $channel;
    if ($topic) {
        $topic{id $self} = $self->stripc($topic);
    } else {
        $topic{id $self} = undef;
    }
}

method run {
    my ($server)   = $self->server;
    my ($origin)   = $self->origin;
    my ($channame) = $channel{id $self};
    my ($topic)    = $topic{id $self};
    my ($channel, $message);

    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    unless ($channame) {
        $origin->numeric(ERR_NEEDMOREPARAMS, 'TOPIC');
        return;
    }

    unless ($channel = $server->find_channel($channame)) {
        $origin->numeric(ERR_NOSUCHCHANNEL, $channame);
        return;
    }

    unless (defined($topic)) {
        if ($channel->topic) {
            $origin->numeric(RPL_NOTOPIC, $channel->name);
        } else {
            $origin->numeric(RPL_TOPIC, $channel->name, $channel->topic);
        }
        return;
    }

    unless ($origin->is_on($channel) or $origin->is_supervisor) {
        $origin->numeric(ERR_NOTONCHANNEL, $channame);
        return;
    }

    unless ($origin->is_op($channel) or $origin->is_supervisor) {
        $origin->numeric(ERR_NOTONCHANNEL, $channel);
        return;
    }

    $message = "TOPIC @{[$channel->name]} :$topic";
    $channel->set_topic($topic);
    $channel->broadcast($origin->prefix($message));
}

1;