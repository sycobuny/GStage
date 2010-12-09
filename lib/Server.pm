#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Server.pm: core server; accept and manage connections, users and channels
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Server;

use warnings;
use strict;
use Method::Signatures;

use IO::Socket::INET;
use IO::Select;

use Command;
use User;
use Channel;

# class variables
our (
    %name,        # server name
    %network,     # IRC network
    %port,        # port clients will connect to
    %socket,      # duh.
    %userlist,    # duh.
    %channellist, # duh.
    %banlist,     # user blacklist for connecting
    %supervisors, # a list of registered supervisors
    %supercount,  # a separate count of supervisors (to preserve a bug)
    %eventlist,   # pending events, handled elsewhere
);
Class::self->private_variables qw(
    socket userlist channellist banlist eventlist
);
Class::self->readable_variables qw(name network port);

my (@motd);

########
# public
########

method initialize($name, $network, $port = 6667) {
    my ($socket, $select, $userlist, $eventlist, @sockets);

    $name{id $self}        = $name;
    $network{id $self}     = $network;
    $port{id $self}        = $port;
    $socket{id $self}      = $socket = IO::Socket::INET->new(
        LocalAddr => 'localhost', # "$name.$network",
        LocalPort => $port,
        Proto     => 'tcp',
        Listen    => 10,
    );
    $userlist{id $self}    = $userlist = {};
    $channellist{id $self} = {};
    $banlist{id $self}     = {};
    $eventlist{id $self}   = $eventlist = {};
    $supervisors{id $self} = {};
    $supercount{id $self}  = 0;

    $select = IO::Select->new($socket);

    print "Server set up at @{[$self->address]}, looping...\n";

    while ($self->is_running) {
        @sockets = $select->can_read(0.5);

        foreach my $rsocket (@sockets) {
            if ($rsocket == $socket) {
                my ($csocket, $user);

                $csocket = $rsocket->accept();
                $csocket->blocking(1);
                $user = User->new($self, $csocket);

                if ($self->is_banned($csocket)) {
                    $user->numeric(Numeric::ERR_YOUREBANNEDCREEP);
                    $csocket->close();
                } else {
                    $select->add($csocket);
                    $userlist{$user->id} = $user;
                }
            } else {
                my ($user) = User->find_user($rsocket);
                $user->read_data();
            }
        }

        # $eventlist->run();
    }

    $self;
}

method register($user, $nickname) {
    my ($userlist) = $userlist{id $self};
    my (@channels, %voices, %halfops, %ops) = $user->channels;

    if ($user->nickname) {
        foreach my $channel (@channels) {
            my ($match) = $channel->match;

            $voices{$match}  = $channel->is_voice($user);
            $halfops{$match} = $channel->is_halfop($user);
            $ops{$match}     = $channel->is_op($user);

            $channel->delete_user($user);
        }

        delete($userlist->{ $user->match });

        foreach my $channel (@channels) {
            my ($match) = $channel->match;

            $channel->add_user($user);

            $channel->voice($user)  if $voices{$match};
            $channel->halfop($user) if $halfops{$match};
            $channel->op($user)     if $ops{$match};
        }
    }

    $userlist->{ $user->match } = $user;
}

method find_user($nickname) {
    my ($userlist) = $userlist{id $self};

    exists($userlist->{lc $nickname}) ? $userlist->{lc $nickname} : undef;
}

method welcome($user) {
    $user->numeric(Numeric::RPL_WELCOME, $user->nickname);
    $user->numeric(Numeric::RPL_YOURHOST, $self->address);
    $user->numeric(Numeric::RPL_CREATED, 'time, which bitches love.');
    $user->numeric(Numeric::RPL_MYINFO, 'GStage', '0.1', 'qs', 'imnst');

    $self->send_motd($user);
}

method send_motd($user) {
    local ($_);

    $user->numeric(Numeric::RPL_MOTDSTART, $self->address);
    $user->numeric(Numeric::RPL_MOTD, $_)
        foreach @motd;
    $user->numeric(Numeric::RPL_ENDOFMOTD);
}

method address { "$name{id $self}.$network{id $self}" }

method is_banned { 0 }

method is_running { 1 }

################
# initialization
################

{
    if ((my $fh = IO::File->new)->open("etc/MOTD", 'r')) {
        @motd = $fh->getlines();
        chomp @motd;
    } else {
        print "Couldn't read etc/MOTD, sup wit dat?\n";
        exit(0);
    }
}

1;
