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
    %socket,      # the main listen socket for the server
    %select,      # the select() queue for checking read/connect readiness
    %uuserlist,   # unregistered user list
    %userlist,    # registered user list
    %channellist, # all channels
    %banlist,     # user blacklist for connecting
    %supervisors, # a list of registered supervisors
    %supercount,  # a separate count of supervisors (to preserve a bug)
    %eventlist,   # pending events, handled elsewhere
    %created,     # when the server was started
);
Class::self->private_variables qw(
    socket select userlist channellist banlist eventlist
);
Class::self->readable_variables qw(name network port created);

my (@motd);

########
# public
########

method initialize($name, $network, $port = 6667) {
    my ($socket, $select, $uuserlist, $userlist, $eventlist, @sockets);

    $name{id $self}        = $name;
    $network{id $self}     = $network;
    $port{id $self}        = $port;
    $socket{id $self}      = $socket = IO::Socket::INET->new(
        LocalAddr => 'localhost', # "$name.$network",
        LocalPort => $port,
        Proto     => 'tcp',
        Listen    => 10,
    );
    $uuserlist{id $self}   = $uuserlist = {};
    $userlist{id $self}    = $userlist = {};
    $channellist{id $self} = {};
    $banlist{id $self}     = {};
    $eventlist{id $self}   = $eventlist = {};
    $supervisors{id $self} = {};
    $supercount{id $self}  = 0;
    $created{id $self}     = localtime;

    $select{id $self} = $select = IO::Select->new($socket);

    $SIG{INT} = sub {
        print "Caught sigint, exiting...\n";

        foreach my $sock ($select->handles) { $sock->close() }
        exit(0);
    };

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
                    $uuserlist{id $user} = $user;
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

    # remove any unregistered entry for this user
    delete $uuserlist{id $self}{id $user};

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

    $userlist->{ User->generate_match($nickname) } = $user;
}

method disconnect($socket, $message?) {
    my ($user) = User->find_user($socket);

    if ($user->is_registered) {
        my ($qmessage) = $user->prefix("QUIT :(signed off)");
        my (@channels) = $user->channels;
        my (@users, %users);

        foreach my $channel (@channels) {
            foreach my $u ($channel->users) { $users{$u->match} = $u }
            $channel->delete_user($user);
        }

        delete $users{$user->match}; # we handle the user itself later
        foreach my $u (values %users) { $u->write($qmessage) }

        delete($uuserlist{id $self}{id $user});
        delete($userlist{id $self}{$user->match});
        $select{id $self}->remove($user->socket);

        $socket->blocking(0);
        $socket->write($qmessage);
    }

    $socket->close();
}

method create_channel($channel) {
    $channellist{id $self}{$channel->match} = $channel;
}

method destroy_channel($channel) {
    delete $channellist{id $self}{$channel->match};
}

method find_channel($channame) {
    my ($chanlist) = $channellist{id $self};
    my ($match) = Channel->generate_match($channame);

    exists($chanlist->{$match}) ? $chanlist->{$match} : undef;
}

method find_user($nickname) {
    my ($userlist) = $userlist{id $self};
    my ($match) = User->generate_match($nickname);

    exists($userlist->{$match}) ? $userlist->{$match} : undef;
}

method welcome($user) {
    $user->numeric(Numeric::RPL_WELCOME, $user->nickname);
    $user->numeric(Numeric::RPL_YOURHOST, $self->address);
    $user->numeric(Numeric::RPL_CREATED, $self->created);
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

method is_supervisor($user) {
    my ($supervisors) = $supervisors{id $self};

    exists($supervisors->{id $user}) and defined($supervisors->{id $user});
}

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
