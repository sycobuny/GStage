package Command::NICK;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NONICKNAMEGIVEN
    ERR_ERRONEOUSNICKNAME
    ERR_NICKNAMEINUSE
    ERR_NICKCOLLISION
);

our (%nickname);
Class::self->readable_variables qw(nickname);

method parse($arguments) {
    my ($n) = split(' ', $arguments);
    $nickname{id $self} = $self->stripc($n);
}

method run {
    my ($origin, $server, $nickname, $message);

    $origin = $self->origin;
    $server = $self->server;
    $nickname = $nickname{id $self};

    unless ($nickname) {
        $origin->numeric(ERR_NONICKNAMEGIVEN);
        return;
    }

    if ($origin->nickname) {
        if ($origin->is_supervisor) {
            if ($server->find_user($nickname)) {
                $origin->numeric(ERR_NICKNAMEINUSE, $nickname);
                return;
            }

            $message = $origin->prefix("NICK $nickname");
            $origin->set_nickname($nickname);

            foreach my $channel ($origin->channels) {
                $channel->broadcast('write', 0, $message);
            }
        } else {
            $origin->numeric(ERR_ERRONEOUSNICKNAME, $nickname);
        }
    } else {
        $origin->set_nickname($nickname);
        $server->welcome($origin)
            if ($origin->username);
    }
}

1;
