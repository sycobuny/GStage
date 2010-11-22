package User;

use warnings;
use strict;
use Method::Signatures;

method handle_join($arguments) {
    print "user at @{[$self->socket->peerhost]} is joining @{[$arguments->{channel}]}\n";
}

method handle_privmsg($arguments) {
    print "user at @{[$self->socket->peerhost]} is messaging @{[$arguments->{target}]} with @{[$arguments->{message}]}\n";
}

1;
