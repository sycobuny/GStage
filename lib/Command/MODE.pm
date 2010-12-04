package Command::MODE;
@ISA = qw(Command);

use warnings;
use strict;
use Method::Signatures;

our (%target, %operation, %mode, %parameter);
Class::self->readable_variables qw(target operation mode parameter);

method parse($arguments) {
    my ($t, $m, $p) = split(' ', $arguments);
    my ($o);

    $o = substr($m, 0, 1);
    $m = substr($m, 1, 1);

    $target{id $self} = $t;
    $operation{id $self} = $o;
    $mode{id $self} = $self->stripc($m);
    $parameter{id $self} = $p;
}

method run {
    print "running a MODE of @{[$self->operation]}@{[$self->mode]} ";
    print "to @{[$self->target]}";
    print $self->parameter ? " with parameter @{[$self->parameter]}" : '';
    print "\n";
}

1;
