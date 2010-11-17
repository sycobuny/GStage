package GStage;

use warnings;
use strict;
use IO::Socket::INET;
use IO::Select;
use Method::Signatures;
use Hash::Util::FieldHash qw(id);

# class variables
Hash::Util::FieldHash::idhashes \ my(
    %name,      # server name
    %network,   # IRC network
    %port,      # port clients will connect to
    %socket,    # duh.
    %banlist,   # user blacklist for connecting
    %eventlist, # pending events, handled elsewhere
);

my ($register);

########
# public
########

method new($class: $name, $network, $port = 6667) {
    my ($self) = bless(\my($o), ref($class)||$class);
    my ($socket, $select, $eventlist, @sockets);

    $name{id $self}      = $name;
    $network{id $self}   = $network;
    $port{id $self}      = $port;
    $socket{id $self}    = $socket = IO::Socket::INET->new(
        LocalAddr => "$name.$network",
        LocalPort => $port,
        Proto     => 'tcp',
        Listen    => 10,
    );
    $banlist{id $self}   = {};
    $eventlist{id $self} = $eventlist = {};
    $self->$register(\(%name, %network, %port, %socket, %banlist, %eventlist));

    $select = IO::Select->new($socket);

    print "Server setup at $name.$network, looping...\n";

    while ($self->is_running) {
        @sockets = $select->can_read(0.5);

        foreach my $rsocket (@sockets) {
            if ($rsocket == $socket) {
                my ($csocket, $user);

                $csocket = $rsocket->acccept();
                $csocket->blocking(1);

                if ($self->is_banned($csocket)) {
                    # print Numeric::ERR_YOUREBANNEDCREEP
                    # disconnect user
                } else {
                    $user = User->new($self, $csocket);
                    $select->add($csocket);
                }
            } else {
                my ($input);
                if ($rsocket->sysread($input, 512)) {
                    print "Yay! Got $input";
                } else {
                    print "sadface no input :(\n";
                }
                # read text from client
                # dispatch events
            }
        }

        # $eventlist->run();
    }

    $self;
}

method is_running { 1 }

#########
# private
#########

$register = method {
    Hash::Util::FieldHash::register($self, @_);
};

1;
