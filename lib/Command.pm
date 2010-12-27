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

# import all available commands
BEGIN {
    foreach my $file (glob 'lib/Command/*.pm') {
        my ($module) = $file =~ m{lib/Command/(.*)\.pm};

        require $file;
        "Command::$module"->import();
    }
}

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
