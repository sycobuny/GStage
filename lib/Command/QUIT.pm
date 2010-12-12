#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/QUIT.pm: handle QUIT commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::QUIT;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%message);
Class::self->readable_variables qw(message);

method parse($arguments) {
    $message{id $self} = $self->stripc($arguments);
}

method run {
    $self->server->disconnect( $self->origin->socket, $self->message );
}

1;
