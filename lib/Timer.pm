# this class is a pretty straightforward port of the Timer class from the
# rhuidean ruby IRC library by rakaur. Note that while Ruby is thread-safe by
# default, perl is not. I intend to work on this and make it more intelligent
# later, once I really understand Perl threads, but this does the job for now.

package Timer;

use warnings;
use strict;
use threads;
use threads::shared;
use Hash::Util::FieldHash qw(id);
use Method::Signatures;

Hash::Util::FieldHash::idhashes \ our (
    %thread,
    %time,
    %repeat,
    %block,
);

method new($class: $time, $repeat, $block) {
    my ($self) = bless(\my($o), ref($class)||$class);

    $time{id $self} = $time;
    $repeat{id $self} = $repeat;
    $block{id $self} = $block;
    $thread{id $self} = threads->new(sub {
        while (1) {
            sleep($time);
            $block->();

            last unless $repeat;
        }
    });

    Hash::Util::FieldHash::register($self);
    Hash::Util::FieldHash::register($self, \(
        %thread, %time, %repeat, %block
    ));

    return $self;
}

method after($class: $time, $block) {
    $class->new($time, 0, $block);
}

method every($class: $time, $block) {
    $class->new($time, 1, $block);
}

method stop {
    $thread{id $self}->exit();
}

method time { $time{id $self} }
method repeat { $repeat{id $self} }

1;
