#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/PART.pm: handle PART commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::PART;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%channel);
Class::self->readable_variables qw(channel);

method parse($arguments) {
    my ($c) = split(' ', $arguments);
    $channel{id $self} = $self->stripc($c);
}

method run {
    print "running a PART from @{[$self->channel]}\n";
}

1;
