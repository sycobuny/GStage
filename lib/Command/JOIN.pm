#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/JOIN.pm: handle JOIN commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::JOIN;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NEEDMOREPARAMS
    ERR_BANNEDFROMCHAN
    ERR_INVITEONLYCHAN
    ERR_BADCHANNELKEY
    ERR_CHANNELISFULL
    ERR_BADCHANMASK
    ERR_NOSUCHCHANNEL
    ERR_TOOMANYCHANNELS
    RPL_TOPIC
    RPL_NAMEREPLY
    RPL_ENDOFNAMES
);

our (%channels, %keys);
Class::self->private_variables qw(channels keys);

my ($chanre) = qr/^(?:\&|\#)/;

method initialize($server, $origin, $arguments) {
    $channels{id $self} = [];
    $keys{id $self} = [];

    $self->SUPER::initialize($server, $origin, $arguments);
}

method parse($arguments) {
    my ($c, $k) = split(' ', $arguments);

    @{ $channels{id $self} } = split(',', ($c || ''));
    @{ $keys{id $self} } = split(',', ($k || ''));
}

method run {
    my ($origin) = $self->origin;
    my ($server) = $self->server;
    my (@channels) = @{ $channels{id $self} };
    my (@keys) = @{ $keys{id $self} };

    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    unless (@channels) {
        $origin->numeric(ERR_NEEDMOREPARAMS, 'JOIN');
        return;
    }

    foreach my $x (0 .. (scalar(@channels) - 1)) {
        local ($_);
        my ($channame) = $channels[$x];
        my ($key) = $keys[$x];
        my ($channel, $users, @users);

        unless ($channame =~ $chanre) {
            $origin->numeric(ERR_NOSUCHCHANNEL, $channame);
            next;
        }

        $channel = $server->find_channel($channame);

        unless ($channel) {
            $channel = Channel->new($server, $channame);
            $channel->set_key($key) if $key;
            $channel->add_op($origin);
        }

        if ($channel->is_bozo($origin) and !$origin->is_supervisor) {
            $origin->numeric(ERR_BANNEDFROMCHAN, $channame);
            next;
        }

        $channel->add_user($origin);
        if ($key and $channel->key and ($channel->key eq $key)) {
            $channel->add_op($origin);
        }

        $channel->broadcast($origin->prefix("JOIN $channame"));

        @users = $channel->users;
        $users = join(' ', sort(map {
            my ($user, $prefix) = ($_, '');

            if ($user->is_op($channel))     { $prefix .= '@' }
            if ($user->is_halfop($channel)) { $prefix .= '%' }
            if ($user->is_voice($channel))  { $prefix .= '+' }

            "$prefix@{[$user->nickname]}";
        } @users));

        $origin->numeric(RPL_TOPIC, $channame, $channel->topic);
        $origin->numeric(RPL_NAMEREPLY, $channame, $users);
        $origin->numeric(RPL_ENDOFNAMES, $channame);

        if ($origin->is_supervisor) {
            my ($arguments) = "@{[$channel->name]} :+o @{[$origin->nickname]}";
            Command::MODE($server, $origin, $arguments)->run();
        }
    }
}

method channels { @{ $channels{id $self} } }
method keys { @{ $keys{id $self} } }

1;
