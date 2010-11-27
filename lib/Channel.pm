package Channel;

use warnings;
use strict;
use Method::Signatures;

our (%name, %match);
__PACKAGE__->variables(\(
    %name,      # channel name, as presented on first join
    %match,     # a matchable version, for hash keys/etc. (cached)
    %key,       # a channel key, for auto-opping
    %limit,     # a channel limit
    %permanent, # whether the channel is permanent
    %secret,    # whether the channel is secret
    %topic,     # the topic for the channel
    %userlist,  # list of all users on the channel
    %oplist,    # list of all ops on the channel
    %hoplist,   # list of all half ops on the channel
    %voicelist, # list of all voices on the channel
    %bozolist,  # a list of IPs banned from the channel
));

my (@spoofs);

method initialize($name, $key = '') {
    $name{id $self} = $name;
    $match{id $self} = $self->generate_match($name);

    $limit{id $self}     = undef;
    $permanent{id $self} = 0;
    $secret{id $self}    = 0;

    $topic{id $self} = '(No topic set)';

    $userlist{id $self}  = {};
    $oplist{id $self}    = {};
    $hoplist{id $self}   = {};
    $voicelist{id $self} = {};
    $bozolist{id $self}  = {};
}

method generate_match($class: $name) {
    my ($match) = lc $name;

    foreach my $index (0 .. (length($match) - 1)) {
        substr($match, $x, 1, chr($spoofs[ ord substr($match, $index, 1) ]));
    }

    $match;
}

method users   { values %{ $userlist{id $self} } }
method ops     { values %{ $oplist{id $self} } }
method halfops { values %{ $hoplist{id $self} } }
method voices  { values %{ $voicelist{id $self} } }
method bozos   { keys %{ $bozolist{id $self} } }

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
              240 108 119 112 244 115 105 103 110 097 108 251 252 253 254 255);

1;
