package Command;

use warnings;
use strict;
use Method::Signatures;
use Object;

use Command::JOIN;
use Command::PART;
use Command::KICK;
use Command::PRIVMSG;
use Command::NOTICE;
use Command::PONG;
use Command::NICK;
use Command::USER;
use Command::MODE;
use Command::QUIT;

our (%server, %origin, %arguments);
__PACKAGE__->variables(\(%server, %origin, %arguments));
__PACKAGE__->readers( qw(server origin arguments) );

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
