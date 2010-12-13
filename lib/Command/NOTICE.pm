#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Command/NOTICE.pm: handle NOTICE commands
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Command::NOTICE;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

use Numeric qw(
    ERR_NOTREGISTERED
    ERR_NORECIPIENT
    ERR_NOTEXTTOSEND
    ERR_CANNOTSENDTOCHAN
    ERR_NOTOPLEVEL
    ERR_WILDTOPLEVEL
    ERR_TOOMANYTARGETS
    ERR_NOSUCHNICK
    RPL_AWAY
);

our (%targets, %message);
Class::self->readable_variables qw(targets message);

my ($cmdre) = qr/^([^ ]*) *:?(.*)/;
my ($chanre) = qr/^(?:\&|\#)/;

sub MAX_TARGETS() { 9 }

method parse($arguments) {
    my ($t, $m) = $arguments =~ $cmdre;
    my (@targets) = split(',', $t);

    $targets{id $self} = \@targets;
    $message{id $self} = $m;
}

method run {
    my ($origin, $server, $targets, $message);
    my ($recipients) = 0;
    my (@recipients, %null_recipients, %void_recipients, %bad_recipients);

    $origin = $self->origin;
    $server = $self->server;
    $targets = $targets{id $self};
    $message = $message{id $self};

    unless ($origin->is_registered) {
        $origin->numeric(ERR_NOTREGISTERED);
        return;
    }

    # gagged users simply have their messages dropped
    return if ($origin->gagged and !$origin->is_supervisor);

    unless ($message) {
        $origin->numeric(ERR_NOTEXTTOSEND);
        return;
    }

    unless (@$targets) {
        $origin->numeric(ERR_NORECIPIENT, 'PRIVMSG');
        return;
    }

    foreach my $target (@$targets) {
        my ($recipient);

        # can only send but so many PRIVMSG commands in one go
        last if (++$recipient > MAX_TARGETS);

        # don't bother checking this recipient if we've already checked them
        # and found them wanting
        next if ($bad_recipients{$target} or $void_recipients{$target});

        if ($target =~ $chanre) {
            $recipient = $server->find_channel($target);
        } else {
            $recipient = $server->find_user($target);
        }

        if ($recipient) {
            my ($can_message);

            $can_message = 1 if ($origin->is_supervisor);

            unless ($can_message) {
                if ($recipient->isa('Channel')) {
                    if ($origin->is_on($recipient)) {
                        if ($recipient->moderated) {
                            $can_message = 1
                                if ($recipient->is_voice($origin) ||
                                    $recipient->is_halfop($origin) ||
                                    $recipient->is_op($origin));
                        } else {
                            $can_message = 1;
                        }
                    } else {
                        $can_message = 1 unless ($recipient->message_locked);
                    }
                } elsif ($recipient->isa('User')) {
                    if ($recipient->private) {
                        $void_recipients{$target} = 1;
                    } else {
                        $can_message = 1;
                    }
                }
            }

            unless ($void_recipients{$target}) {
                $bad_recipients{$target} = $can_message unless $can_message;
                push(@recipients, $recipient) if $can_message;
            }
        } else {
            $null_recipients{$target} = 1;
        }
    }

    foreach my $error (keys %null_recipients) {
        $origin->numeric(ERR_NOSUCHNICK, $error);
    }

    foreach my $error (keys %bad_recipients) {
        $origin->numeric(ERR_CANNOTSENDTOCHAN, $error);
    }

    foreach my $recipient (@recipients) {
        my ($target);

        if ($recipient->isa('Channel')) {
            $target = $recipient->name;
            $recipient->broadcast($origin->prefix("PRIVMSG $target :$message"), 1);
        } elsif ($recipient->isa('User')) {
            $target = $recipient->nickname;
            $recipient->write($origin->prefix("PRIVMSG $target :$message"), 1);
        }
    }
}

1;
