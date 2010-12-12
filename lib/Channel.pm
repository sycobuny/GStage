#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Channel.pm: manage channels; membership, state, etc.
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Channel;

use warnings;
use strict;
use Method::Signatures;

our (
    %server,         # the server this channel is located on
    %name,           # channel name, as presented on first join
    %match,          # a matchable version, for hash keys/etc. (cached)
    %key,            # a channel key, for auto-opping
    %limit,          # a channel limit
    %message_locked, # whether the channel is message locked
    %topic_locked,   # whether the channel is topic locked
    %moderated,      # whether the channel is moderated
    %permanent,      # whether the channel is permanent
    %secret,         # whether the channel is secret
    %topic,          # the topic for the channel
    %userlist,       # list of all users on the channel
    %oplist,         # list of all ops on the channel
    %hoplist,        # list of all half ops on the channel
    %voicelist,      # list of all voices on the channel
    %bozolist,       # a list of IPs banned from the channel
);
Class::self->public_variables qw(key topic);
Class::self->readable_variables qw(
    server name match limit message_locked topic_locked moderated permanent
    secret
);
Class::self->private_variables qw(userlist oplist hoplist voicelist bozolist);

my ($add_user, $check_user, $delete_user, $set, $unset);
my (@spoofs);

sub BOZO_TIMEOUT() { 180 }

########
# public
########

method initialize($server, $name) {
    $server{id $self} = $server;
    $name{id $self} = $name;
    $match{id $self} = $self->generate_match($name);

    $limit{id $self}          = undef;
    $message_locked{id $self} = 1;
    $topic_locked{id $self}   = 1;
    $permanent{id $self}      = 0;
    $secret{id $self}         = 0;

    $topic{id $self} = '(No topic set)';

    $userlist{id $self}  = {};
    $oplist{id $self}    = {};
    $hoplist{id $self}   = {};
    $voicelist{id $self} = {};
    $bozolist{id $self}  = {};

    $server->create_channel($self);
}

method generate_match($class: $name) {
    my ($match) = lc $name;

    foreach my $x (0 .. (length($match) - 1)) {
        substr($match, $x, 1, chr($spoofs[ ord substr($match, $x, 1) ]));
    }

    $match;
}

method broadcast($message) {
    foreach my $user (values %{ $userlist{id $self} }) {
        $user->write($message);
    }
}

method add_user($user) {
    $self->$add_user($user, \%userlist);
    $user->add_to_channel($self);
}

method is_on($user) {
    $self->$check_user($user, \%userlist);
}

method delete_user($user) {
    $self->$delete_user($user, \%userlist);

    $self->delete_op($user);
    $self->delete_halfop($user);
    $self->delete_voice($user);

    $user->remove_from_channel($self);

    unless (scalar(keys %{ $userlist{id $self} }) or $self->permanent) {
        $self->server->destroy_channel($self);
    }
}

method add_op($user)    { $self->$add_user($user, \%oplist) }
method is_op($user)     { $self->$check_user($user, \%oplist) }
method delete_op($user) { $self->$delete_user($user, \%oplist) }

method add_halfop($user)    { $self->$add_user($user, \%hoplist) }
method is_halfop($user)     { $self->$check_user($user, \%hoplist) }
method delete_halfop($user) { $self->$delete_user($user, \%hoplist) }

method add_voice($user)    { $self->$add_user($user, \%voicelist) }
method is_voice($user)     { $self->$check_user($user, \%voicelist) }
method delete_voice($user) { $self->$delete_user($user, \%voicelist) }

method add_bozo($user) {
    my ($bozos) = $bozolist{id $self};
    $bozos->{ $user->socket->peerhost } = scalar(localtime) + BOZO_TIMEOUT;
}

method is_bozo($user) {
    my ($bozos) = $bozolist{id $self};
    my ($peerhost) = $user->socket->peerhost;

    exists($bozos->{$peerhost}) and defined($bozos->{$peerhost}) and
    (scalar(localtime) >= $bozos->{$peerhost});
}

method remove_bozo($user) {
    my ($bozos) = $bozolist{id $self};
    delete $bozos->{ $user->socket->peerhost };
}

method bozos {
    my ($bozos) = $bozolist{id $self};

    foreach my $peerhost (keys %$bozos) {
        delete $bozos->{$peerhost}
            if ($bozos->{$peerhost} < scalar(localtime));
    }

    keys %$bozos;
}

method bozo_timeout($peerhost) {
    my ($bozos) = $bozolist{id $self};
    exists($bozos->{$peerhost}) ? $bozos->{$peerhost} : 0;
}

method set_limit($limit) {
    return unless $limit =~ /^\d+$/;
    $limit{id $self} = $limit;
}

method unset_limit { $limit{id $self} = undef }

method set_message_locked { $self->$set(\%message_locked) }
method set_topic_locked   { $self->$set(\%topic_locked) }
method set_moderated      { $self->$set(\%moderated) }
method set_permanent      { $self->$set(\%permanent) }
method set_secret         { $self->$set(\%secret) }

method unset_message_locked { $self->$unset(\%message_locked) }
method unset_topic_locked   { $self->$unset(\%topic_locked) }
method unset_moderated      { $self->$unset(\%moderated) }
method unset_permanent      { $self->$unset(\%permanent) }
method unset_secret         { $self->$unset(\%secret) }

method users   { values %{ $userlist{id $self} } }
method ops     { values %{ $oplist{id $self} } }
method halfops { values %{ $hoplist{id $self} } }
method voices  { values %{ $voicelist{id $self} } }

#########
# private
#########

$add_user = method($user, $listref) {
    $listref->{id $self}{$user->match} = $user;
};

$check_user = method($user, $listref) {
    my ($list) = $listref->{id $self};
    exists($list->{$user->match}) and defined($list->{$user->match});
};

$delete_user = method($user, $listref) {
    delete $listref->{id $self}{$user->match};
};

$set   = method($mode) { $mode->{id $self} = 1 };
$unset = method($mode) { $mode->{id $self} = 0 };

@spoofs =  qw(000 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015
              016 017 018 019 020 021 022 023 024 025 026 027 028 029 030 031
              032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047
              048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063
              064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079
              080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095
              096 097 098 099 100 101 102 103 104 105 106 107 108 109 110 111
              112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127
              128 129 105 114 116 117 097 108 136 137 105 109 101 114 142 143
              120 112 105 114 101 100 150 151 114 111 102 105 108 105 110 103
              160 161 105 109 101 114 166 167 120 112 105 114 101 100 174 175
              112 117 178 179 105 109 105 116 184 185 120 099 101 101 100 101
              100 193 194 105 108 101 198 199 105 122 101 203 204 105 109 105
              116 209 210 120 099 101 101 100 101 100 218 219 111 221 114 117
              110 110 097 098 108 101 230 108 119 112 234 235 110 116 101 114
              240 108 119 112 244 115 105 103 110 097 108 251 252 253 254 255
             );

1;
