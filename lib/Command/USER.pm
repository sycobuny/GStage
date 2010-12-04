package Command::USER;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

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
    print "running a USER for @{[$self->username]}, ";
    print "from @{[$self->hostname]}, ";
    print "connecting to @{[$self->hostname]}, ";
    print "known in real life as @{[$self->realname]}\n";
}

1;
