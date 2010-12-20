#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/MODE.pm: handle MODE commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::MODE;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NEEDMOREPARAMS
    ERR_CHANOPRIVSNEEDED
    ERR_NOSUCHNICK
    ERR_NOTONCHANNEL
    ERR_USERNOTINCHANNEL
    ERR_KEYSET
    ERR_UNKNOWNMODE
    ERR_NOSUCHCHANNEL
    ERR_USERSDONTMATCH
    ERR_UMODEUNKNOWNFLAG
    ERR_NOPRIVILEGES
    RPL_CHANNELMODEIS
    RPL_BANLIST
    RPL_ENDOFBANLIST
    RPL_UMODEIS
);

our (%target, %operation, %mode, %parameter);
Class::self->readable_variables qw(target operation mode parameter);

my ($chanre) = qr/^(?:\&|\#)/;
my ($opre) = qr/^(\+|-)$/;
my ($numre) = qr/^[0-9]+$/;
my (%mode_lists);
my (%mode_commands);

sub PRIVS_ANY()    { 0 }
sub PRIVS_SUPER()  { 1 }
sub PRIVS_OP()     { 2 }
sub PRIVS_HALFOP() { 3 }

sub PARAM_NONE()  { undef }
sub PARAM_OPT()   { 0x0 }
sub PARAM_SET()   { 0x1 }
sub PARAM_UNSET() { 0x2 }
sub PARAM_BOTH()  { PARAM_SET | PARAM_UNSET }
sub PARAM_USER()  { 0x4 }

sub ECHO_NONE() { 0x0 }
sub ECHO_SELF() { 0x1 }
sub ECHO_RECP() { 0x2 }
sub ECHO_ALL()  { ECHO_SELF | ECHO_RECP }

method parse($arguments) {
    my ($t, $m, $p) = split(' ', $arguments);
    my ($o);

    $m = $self->stripc($m || '');
    $o = substr($m, 0, 1);
    $m = length($m) > 1 ? substr($m, 1, 1) : '';

    $target{id $self} = $t;
    $operation{id $self} = $o;
    $mode{id $self} = $m;
    $parameter{id $self} = $p;
}

method run {
    my ($server, $origin, $operation, $target, $mode, $parameter);
    my ($receiver, $mode_opts, $command);

    $server = $self->server;
    $origin = $self->origin;

    $operation = $operation{id $self};
    $target    = $target{id $self};
    $mode      = $mode{id $self};
    $parameter = $parameter{id $self};

    # user has to be registered to request or change modes
    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    # target must always be provided
    unless ($target) {
        $origin->numeric(ERR_NEEDMOREPARAMS, 'MODE');
        return;
    }

    # get the mode command list for the relevant target object
    if ($target =~ $chanre) {
        $receiver = $server->find_channel($target);
        $mode_opts = $mode_commands{Channel}{$mode};

        unless ($receiver) {
            $origin->numeric(ERR_NOSUCHCHANNEL, $target);
            return;
        }
    } else {
        $receiver = $server->find_user($target);
        $mode_opts = $mode_commands{User}{$mode};

        unless ($receiver) {
            $origin->numeric(ERR_NOSUCHNICK, $target);
            return;
        }

        unless (($origin == $receiver) or $origin->is_supervisor) {
            $origin->numeric(ERR_USERSDONTMATCH);
            return;
        }
    }

    # verify operation has a mode or else send the mode list requested
    if ($operation) {
        unless ($mode) {
            $origin->numeric(ERR_NEEDMOREPARAMS, 'MODE');
            return;
        }
    } else {
        my ($mlist) = '';

        if ($receiver->isa('Channel')) {
            my (@params);

            foreach my $mode (sort keys %{ $mode_lists{Channel} }) {
                my ($opts) = $mode_lists{Channel}{$mode};
                my ($query) = $opts->{command};
                my ($setting) = $receiver->$query();

                $mlist .= $mode if ($setting);
                push(@params, $setting) if ($setting and $opts->{as_param});
            }

            $mlist = join(' ', ($mlist, @params));
            $origin->numeric(RPL_CHANNELMODEIS, $target, "+$mlist");
        } else {
            unless ($origin == $receiver) {
                $origin->numeric(ERR_USERSDONTMATCH);
                return;
            }

            foreach my $mode (sort keys %{ $mode_lists{User} }) {
                my ($query) = $mode_lists{User}{$mode};
                $mlist .= $mode if ($receiver->$query());
            }

            $origin->numeric(RPL_UMODEIS, "+$mlist");
        }

        return;
    }

    if ($receiver->isa('Channel')) {
        unless ($mode_opts and ($operation =~ $opre)) {
            $origin->numeric(ERR_UMODEUNKNOWNFLAG);
            return;
        }
    } else {
        unless ($mode_opts and (($operation) = $operation =~ $opre)) {
            $origin->numeric(ERR_UNKNOWNMODE, $operation ? $operation : $mode);
            return;
        }
    }

    # check parameter requirement
    if ($mode_opts->{params}) {
        if ($mode_opts->{params} & PARAM_USER) {
            my ($user) = $server->find_user($parameter);
            unless ($parameter) {
                $origin->numeric(ERR_NOSUCHNICK, $parameter);
                return;
            }

            unless ($user->is_on($receiver)) {
                $origin->numeric(ERR_USERNOTINCHANNEL, $parameter, $target);
                return;
            }

            $parameter = $user;
        }

        if (($self->up and ($mode_opts->{params} & PARAM_SET)) or
            ($self->down and ($mode_opts->{params} & PARAM_UNSET))) {
            unless ($parameter) {
                $origin->numeric(ERR_NEEDMOREPARAMS, 'MODE');
                return;
            }
        }
    } elsif (!defined($mode_opts->{params})) { # special case, never send
        $parameter = '';
    }

    # check privileges
    foreach my $level ($mode_opts->{privs}) {
        my ($approved) = $level ? 0 : 1;
        $level ||= 0;

        ($level >= PRIVS_SUPER) && do {
            $approved = 1 if ($origin->is_supervisor);
        };

        ($level >= PRIVS_OP) && do {
            $approved = 1 if ($origin->is_op($receiver));
        };

        ($level >= PRIVS_HALFOP) && do {
            $approved = 1 if ($origin->is_halfop($receiver));
        };

        unless ($approved) {
            if ($level == PRIVS_SUPER) {
                $origin->numeric(ERR_NOPRIVILEGES);
            } else {
                $origin->numeric(ERR_CHANOPRIVSNEEDED, $target);
            }
            return;
        }
    }

    # run the mode command
    $command = $mode_opts->{command};
    $self->$command($receiver, $parameter);

    if ($mode_opts->{echo}) {
        my ($message) = $self->message;

        if ($receiver->isa('Channel')) {
            if ($mode_opts->{echo} & ECHO_RECP) {
                $receiver->broadcast($message);
            }

            if ($mode_opts->{echo} & ECHO_SELF) {
                $origin->write($message) unless ($origin->is_on($receiver));
            }
        } else {
            if ($mode_opts->{echo} & ECHO_RECP) {
                $receiver->write($message);
            }

            if ($mode_opts->{echo} & ECHO_SELF) {
                $origin->write($message) unless ($origin == $receiver);
            }
        }
    }

}

method message {
    my ($origin, $target, $operation, $mode, $parameter);
    my ($id) = id $self;

    $origin    = $self->origin;
    $target    = $target{$id};
    $operation = $operation{$id};
    $mode      = $mode{$id};
    $parameter = $parameter{$id};

    $origin->prefix("MODE $target :$operation$mode $parameter");
}

method up()   { $self->operation eq '+' }
method down() { $self->operation eq '-' }

#########
# private
#########

%mode_lists = (
    Channel => {
        f => {
            command  => 'permanent',
            as_param => 0
        },

        k => {
            command  => 'key',
            as_param => 1
        },

        l => {
            command  => 'limit',
            as_param => 1
        },

        m => {
            command  => 'moderated',
            as_param => 0
        },

        n => {
            command  => 'message_locked',
            as_param => 0
        },

        s => {
            command  => 'secret',
            as_param => 0
        },

        t => {
            command  => 'topic_locked',
            as_param => 0
        },
    },

    User => {
        g => 'gagged',
        p => 'private',
        s => 'is_supervisor',
    },
);

%mode_commands = (
    Channel => {
        o => {
            params  => PARAM_BOTH | PARAM_USER,
            privs   => PRIVS_OP,
            echo    => ECHO_ALL,
            command => method ($channel, $user) {
                if ($self->up) {
                    $channel->add_op($user);
                } else {
                    $channel->delete_op($user);
                }
            },
        },

        h => {
            params  => PARAM_BOTH | PARAM_USER,
            privs   => PRIVS_HALFOP,
            echo    => ECHO_ALL,
            command => method ($channel, $user) {
                if ($self->up) {
                    $channel->add_halfop($user);
                } else {
                    $channel->delete_halfop($user);
                }
            },
        },

        v => {
            params  => PARAM_BOTH | PARAM_USER,
            privs   => PRIVS_HALFOP,
            echo    => ECHO_ALL,
            command => method ($channel, $user) {
                if ($self->up) {
                    $channel->add_voice($user);
                } else {
                    $channel->delete_voice($user);
                }
            },
        },

        k => {
            params  => PARAM_BOTH,
            privs   => PRIVS_ANY,
            echo    => ECHO_NONE, # we handle echoing in the method for this one
            command => method ($channel, $key) {
                my ($origin) = $self->origin;

                if ($self->up) {
                    unless ($channel->is_op($self->origin)) {
                        $origin->numeric(ERR_CHANOPRIVSNEEDED, $channel->name);
                        return;
                    }

                    $channel->set_key($key);
                    $origin->write($self->message);
                } else {
                    return unless ($channel->key);
                    return unless ($channel->key eq $key);

                    $channel->add_op($origin);

                    # convert this into an operator mode change
                    $target{id $self}    = $channel->name;
                    $operation{id $self} = '+';
                    $mode{id $self}      = 'o';
                    $parameter{id $self} = $origin->nickname;

                    $channel->broadcast($self->message);
                }
            },
        },

        l => {
            params  => PARAM_SET,
            privs   => PRIVS_OP,
            echo    => ECHO_ALL,
            command => method ($channel, $limit) {
                if ($self->up) {
                    return unless ($limit =~ $numre);
                    $channel->set_limit($limit);
                } else {
                    $channel->unset_limit();
                }
            },
        },

        m => {
            params  => PARAM_NONE,
            privs   => PRIVS_OP,
            echo    => ECHO_ALL,
            command => method ($channel, $parameter) {
                if ($self->up) {
                    $channel->set_moderated();
                } else {
                    $channel->unset_moderated();
                }
            },
        },

        n => {
            params  => PARAM_NONE,
            privs   => PRIVS_OP,
            echo    => ECHO_ALL,
            command => method ($channel, $parameter) {
                if ($self->up) {
                    $channel->set_message_locked();
                } else {
                    $channel->unset_message_locked();
                }
            },
        },

        t => {
            params  => PARAM_NONE,
            privs   => PRIVS_OP,
            echo    => ECHO_ALL,
            command => method ($channel, $parameter) {
                if ($self->up) {
                    $channel->set_topic_locked();
                } else {
                    $channel->unset_topic_locked();
                }
            },
        },

        s => {
            params  => PARAM_NONE,
            privs   => PRIVS_OP,
            echo    => ECHO_ALL,
            command => method ($channel, $parameter) {
                $self->up ? $channel->set_secret() : $channel->unset_secret();
            },
        },

        b => {
            params  => PARAM_OPT,
            privs   => PRIVS_ANY,
            echo    => ECHO_NONE,
            command => method ($channel, $parameter) {
                if ($self->down and $parameter) {
                    $channel->remove_bozo($parameter);
                }

                # XXX have "system" send the bozo list
            },
        },

        f => {
            params  => PARAM_NONE,
            privs   => PRIVS_SUPER,
            echo    => ECHO_ALL,
            command => method ($channel, $parameter) {
                if ($self->up) {
                    $channel->set_permanent();
                } else {
                    $channel->unset_permanent();
                }
            },
        },

    },

    User => {
        p => {
            echo    => ECHO_ALL,
            command => method ($user, $parameter) {
                $self->up ? $user->set_private() : $user->unset_private();
            },
        },

        q => {
            params  => PARAM_SET,
            command => method ($user, $qlimit) {
                if ($self->up) {
                    return unless ($qlimit =~ $numre);
                    $user->set_qlimit($qlimit);
                } else {
                    $user->set_qlimit(User::DEF_QLIMIT);
                }

                # XXX have "system" send the qlimit
            },
        },

        s => {
            params  => PARAM_OPT,
            command => method ($user, $superpass) {
                my ($server) = $self->server;
                my ($origin) = $self->origin;
                my ($message) = $self->message;

                if ($self->up) {
                    if ($origin == $user) {
                        unless ($superpass) {
                            $origin->numeric(ERR_NEEDMOREPARAMS, 'MODE');
                            return;
                        }
                        return unless ($server->superpass eq $superpass);
                    } else {
                        $parameter{id $self} = '';
                        $message = $self->message;
                    }

                    $parameter{id $self} = '';
                    $server->add_supervisor($user);

                    $user->write($self->message);
                    $origin->write($self->message);
                } else {
                    $server->delete_supervisor($user);

                    $user->write($self->message);
                    $origin->write($self->message) unless ($user == $origin);
                }
            },
        },

        z => {
            command => method ($user, $parameter) {
                my ($server) = $self->server;
                my ($origin) = $self->origin;
                $server->disconnect($user, "KILL from @{[$origin->nickname]}");
            },
        },
    },
);

1;
