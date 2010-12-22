#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command.pm: abstract base class for dealing with IRC commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command;

use warnings;
use strict;
use Method::Signatures;
use Object;

use Command::JOIN;
use Command::KICK;
use Command::LIST;
use Command::MODE;
use Command::NICK;
use Command::NOTICE;
use Command::PART;
use Command::PONG;
use Command::PRIVMSG;
use Command::QUIT;
use Command::TOPIC;
use Command::USER;
use Command::WHO;
use Command::WHOIS;

our (%server, %origin, %arguments);
Class::self->readable_variables qw(server origin arguments);

method new_from_command($class: $command, $server, $origin, $arguments) {
    my ($klass) = Class::get('Command::' . uc($command));
    return unless $klass;

    $klass->new($server, $origin, $arguments);
}

method initialize($server, $origin, $arguments) {
    $server{id $self} = $server;
    $origin{id $self} = $origin;
    $arguments{id $self} = $arguments;

    $self->parse($arguments);
}

method stripc($cmd_string) {
    ($cmd_string =~ /^:/) ? substr($cmd_string, 1) : $cmd_string;
}

method parse { 0 }
method run { 0 }

1;
