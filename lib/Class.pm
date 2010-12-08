#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Class.pm: helper methods for dealing with Perl classes
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Class;

use warnings;
use strict;
use Method::Signatures;

method new($class:) {
    die "Can't instantiate a class!\n";
}

func in {
    my ($package) = caller;
    Class::exists($package) ? $package : undef;
}
*self = *in{CODE};

func exists($class) {
    no strict 'refs';
    scalar(%{$class . '::'});
}

func get($class) {
    my ($package) = ref($class) || $class;
    Class::exists($package) ? $package : undef;
}

1;
