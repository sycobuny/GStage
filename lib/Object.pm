#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Object.pm: provide better OOP behavior for Perl
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Object;

use warnings;
use strict;

use Method::Signatures;
use Scalar::Util qw();
use Hash::Util::FieldHash qw(id);

use Class;
unshift(@UNIVERSAL::ISA, Class::self);

my ($uuid) = 0;
my ($generate_uuid) = sub { ++$uuid };
my ($declare_variable);
my (%objlookup);
my (%vars);

########
# public
########

method private_variables($class: @variables) {
    my ($package) = Class::get($class);

    foreach my $variable (@variables) {
        $class->$declare_variable($variable);
    }
}

method readable_variables($class: @variables) {
    my ($package) = Class::get($class);

    {
        no strict 'refs';

        foreach my $variable (@variables) {
            my ($store) = $package->$declare_variable($variable);
            my ($glob) = *{"$package\::$variable"}{GLOB};
            die "Method $variable already exists in $package\n"
                if (*$glob{CODE});

            *$glob = method { $store->{id $self} };
        }
    }
}

method writeable_variables($class: @variables) {
    my ($package) = Class::get($class);

    {
        no strict 'refs';

        foreach my $variable (@variables) {
            my ($store) = $package->$declare_variable($variable);
            my ($glob) = *{"$package\::set_$variable"}{GLOB};
            die "Method set_$variable already exists in $package\n"
                if (*$glob{CODE});

            *$glob = method($value) { $store->{id $self} = $value };
        }
    }
}

method public_variables($class: @variables) {
    $class->readable_variables(@variables);
    $class->writeable_variables(@variables);
}

method new($class:) {
    my ($package) = Class::get($class);
    die "Attempted to create object of undeclared class $class" unless $package;

    my ($self) = bless(\(my $o = $generate_uuid->()), $package);
    $objlookup{$$self} = $self;

    Scalar::Util::weaken($objlookup{$$self});
    Hash::Util::FieldHash::register($self);

    foreach my $varpack ($package->genealogy) {
        Hash::Util::FieldHash::register($self, values %{ $vars{$varpack} });
    }

    $self->initialize(@_);

    $self;
}

method ancestors($class:) {
    local ($_);
    my ($package) = Class::get($class);
    my (@ancestors);

    {
        no strict 'refs';
        @ancestors = @{ $package . '::ISA' };
    }

    @ancestors = ($package eq 'Object') ? () : ('UNIVERSAL')
        unless (@ancestors);
    @ancestors, map { $_->ancestors() } @ancestors;
}

method genealogy($class:) {
    (Class::get($class), $class->ancestors);
}

method methods($class:) {
    my (@classes) = $class->genealogy;
    my (%methods);

    {
        no strict 'refs';

        foreach my $klass (@classes) {
            my ($entries) = *{ $klass . '::' }{HASH};

            foreach my $entry (keys %{ $entries }) {
                $methods{$entry} = 1 if ref(*{$entries->{$entry}}{CODE});
            }
        }
    }

    keys %methods;
}

method variables($class:) {
    local ($_);
    my (@classes) = $class->genealogy;

    map { $vars{$_} ? keys %{ $vars{$_} } : () } @classes;
}

method accessors($class:) {
    $class->readers(@_);
    $class->writers(@_);
}

method initialize { }
method class { ref($self) || 'Class' }

#########
# private
#########

$declare_variable = method($class: $name) {
    my ($package) = Class::get($class);
    my ($store);
    $vars{$package} ||= {};

    {
        no strict 'refs';
        $store = \%{"$package\::$name"};
    }

    Hash::Util::FieldHash::idhashes($store)
        unless ($vars{$package}{$name} &&
                (id($vars{$package}{$name}) == id($store)));
    $vars{$package}{$name} = $store;
};

########################
# some kinda black magic
########################

package CORE;

*CORE::GLOBAL::die = sub {
    use Carp qw();
    CORE::die Carp::longmess(@_);
};

1;
