package Server;

use warnings;
use strict;
use Method::Signatures;

use IO::Socket::INET;
use IO::Select;

use User;
#use Channel;

# class variables
our (%name, %network, %port, %socket, %userlist, %channellist, %banlist,
     %eventlist);
__PACKAGE__->variables(\(
    %name,        # server name
    %network,     # IRC network
    %port,        # port clients will connect to
    %socket,      # duh.
    %userlist,    # duh.
    %channellist, # duh.
    %banlist,     # user blacklist for connecting
    %eventlist,   # pending events, handled elsewhere
));

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

    $select = IO::Select->new($socket);

    print "Server setup at $name.$network, looping...\n";

    while ($self->is_running) {
        @sockets = $select->can_read(0.5);

        foreach my $rsocket (@sockets) {
            if ($rsocket == $socket) {
                my ($csocket, $user);

                $csocket = $rsocket->accept();
                $csocket->blocking(1);

                if ($self->is_banned($csocket)) {
                    # print Numeric::ERR_YOUREBANNEDCREEP
                    # disconnect user
                } else {
                    $user = User->new($self, $csocket);
                    $select->add($csocket);
                    $userlist{$user->id} = $user;
                }
            } else {
                my ($user) = User->find_user($rsocket);
                $user->read_data();
                # read text from client
                # dispatch events
            }
        }

        # $eventlist->run();
    }

    $self;
}

method is_banned { 0 }

method is_running { 1 }

1;