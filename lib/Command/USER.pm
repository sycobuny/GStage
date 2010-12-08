package Command::USER;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_ALREADYREGISTERED
    ERR_NEEDMOREPARAMS
);

our (%username, %hostname, %servername, %realname);
Class::self->readable_variables qw(username hostname servername realname);

my ($re) = qr/
              ^                # anchor to start of string
              ([^\x20]*)\x20 * # username
              ([^\x20]*)\x20 * # hostname
              ([^\x20]*)\x20 * # servername
              :?(.*)           # realname
             /x;               # expanded regex

method parse($arguments) {
    my ($u, $h, $s, $r) = $arguments =~ $re;

    $username{id $self} = $u;
    $hostname{id $self} = $h;
    $servername{id $self} = $s;
    $realname{id $self} = $r;
}

method run {
    my ($origin, $username, $hostname, $servername, $realname);
    $origin = $self->origin;

    if ($origin->username) {
        $origin->numeric(ERR_ALREADYREGISTERED);
        return;
    }

    $username   = $username{id $self};
    $hostname   = $hostname{id $self};
    $servername = $servername{id $self};
    $realname   = $realname{id $self};

    unless ($username && $hostname && $servername && $realname) {
        $origin->numeric(ERR_NEEDMOREPARAMS, 'USER');
        return;
    }

    $origin->set_username($username);
    $origin->set_realname($realname);

    $self->server->welcome($origin)
        if ($origin->nickname);
}

1;
