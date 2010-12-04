package Class;

use warnings;
use strict;
use Method::Signatures;

method new($class:) {
    die "Can't instantiate a class!\n";
}

func exists($class) {
    no strict 'refs';
    scalar(%{$class . '::'});
}

func get($class) {
    my ($package) = ref($class) || $class;
    Class::exists($package) ? $package : undef;
}

1;
