package User;

use warnings;
use strict;
use IO::File;
use Method::Signatures;
use Hash::Util::FieldHash qw(id);

# class variables
Hash::Util::FieldHash::idhashes \ our (
    %server,    # the server we're connected to
    %socket,    # raw connection to the server
    %fragment,  # unfinished line fragment from the socket
    %nickname,  # IRC nickname
    %username,  # IRC username
    %mask,      # the masked host (saving cycles)
    %channels,  # the channels this user has joined
);

my (@masks);

########
# public
########

method new($class: $server, $socket) {
    my ($self) = bless(\my ($o), ref($class)||$class);
    my ($mask, @octets);

    $mask = '';
    @octets = reverse split(/\./, $socket->peerhost);

    foreach my $index (0..3) { $mask .= $masks[$index][ $octets[$index] ] }
    $mask .= 'this.chat.server';

    $server{id $self}   = $server;
    $socket{id $self}   = $socket;
    $mask{id $self}     = $mask;
    $channels{id $self} = {};

    Hash::Util::FieldHash::register($self);
    Hash::Util::FieldHash::register($self, \(
        %server, %socket, %fragment, %nickname, %username, %mask, %channels
    ));

    return $self;
}

method find_user($class: $socket) {
    foreach my $id (keys %socket) {
        return Hash::Util::FieldHash::id_2obj($id)
            if ($socket == $socket{$id});
    }
}

method read_data {
    my ($fragment, $socket, $input);
    $fragment = $fragment{id $self};
    $socket   = $socket{id $self};

    if ($socket->sysread($input, 1024)) {
        my ($line);
        local ($1, $2);

        while ($input =~ /^([^\n]*)\n([^\n]*)/) {
            if ($fragment) {
                $line = "$fragment$1";
                $fragment = ''
            } else {
                $line = $1;
            }

            $self->parse($line);
            $input = $2;
        }

        $fragment = $input;
    } else { print "sad\n" }
}

method parse($line) {
    print "the line I just got was $line!\n";
}

method add_to_channel($channel) {
    my ($channels) = $channels{id $self};
    return if $channels{$channel->name};

    $channels{$channel->name} = $channel;
    $channel->add_user($self);
}

method remove_from_channel($channel) {
    my ($channels) = $channels{id $self};
    return unless $channels{$channel->name};

    delete $channels{$channel->name};
    $channel->delete_user($self);
}

method hostmask {
    sprintf("%s!%s@%s", $nickname{id $self}, $username{id $self},
            $mask{id $self});
}

method server { $server{id $self} }
method channels { values %{ $channels{id $self} } }

foreach my $i (1..4) {
    if ((my $fh = IO::File->new)->open("etc/hostmasks.$i", 'r')) {
        push(@masks, [split(/\s+/, join(' ', $fh->getlines()))]);
    } else {
        print "Couldn't read etc/hostmask.$i, sup wit dat?\n";
        exit(0);
    }
}

1;