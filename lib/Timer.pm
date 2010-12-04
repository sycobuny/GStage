# this class is a pretty straightforward port of the Timer class from the
# rhuidean ruby IRC library by rakaur. Note that while Ruby is thread-safe by
# default, perl is not. I intend to work on this and make it more intelligent
# later, once I really understand Perl threads, but this does the job for now.

package Timer;

use warnings;
use strict;
use Method::Signatures;

use threads;
use threads::shared;

our (%time, %repeat, %block);
Class::self->private_variables qw(block);
Class::self->readable_variables qw(time repeat);

method initialize($time, $repeat, $block) {
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

1;
