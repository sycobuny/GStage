package Object;

use warnings;
use strict;

use Method::Signatures;
use Scalar::Util qw();
use Hash::Util::FieldHash qw(id);

use Class;

unshift(@UNIVERSAL::ISA, __PACKAGE__);

my ($uuid) = 0;
my ($generate_uuid) = sub { ++$uuid };
my (%objlookup);
my (%vars);

method variables($class:) {
    my ($package) = ref($class) || $class;

    Hash::Util::FieldHash::idhashes(@_);
    foreach my $var (@_) {
        $vars{$class} ||= [];

        push(@{ $vars{$package} }, $var)
            if (ref($var) =~ /HASH/);
    }
}

method new($class:) {
    my ($package) = Class::get($class);
    my ($self) = bless(\(my $o = $generate_uuid->()), $package);
    $objlookup{$$self} = $self;

    Scalar::Util::weaken($objlookup{$$self});
    Hash::Util::FieldHash::register($self);

    foreach my $varpack ($package, $self->ancestors) {
        Hash::Util::FieldHash::register($self, @{ $vars{$varpack} });
    }

    $self->initialize(@_);

    $self;
}

method ancestors($class:) {
    my ($package) = Class::get($class);
    my (@ancestors);

    {
        no strict 'refs';
        @ancestors = @{ $package . '::ISA' };
    }

    unless (@ancestors) {
        @ancestors = ($package eq 'Object') ? () : ('UNIVERSAL');
    }

    {
        local ($_);
        return @ancestors, map { $_->ancestors() } @ancestors;
    }
}

method methods($class:) {
    my ($package) = Class::get($class);
    my (@ancestors) = ($package, $class->ancestors);
    my (%methods);

    {
        no strict 'refs';

        foreach my $klass (@ancestors) {
            my ($entries) = *{ $klass . '::' }{HASH};

            foreach my $entry (keys %{ $entries }) {
                $methods{$entry} = 1 if ref(*{$entries->{$entry}}{CODE});
            }
        }
    }

    keys %methods;
}

method variable_stores($class:) {
    local ($_);
    my ($package) = Class::get($class);
    my (@ancestors) = ($package, $class->ancestors);

    map { $vars{$_} ? @{ $vars{$_} } : () } @ancestors;
}

method readers($class:) {
    my ($package) = Class::get($class);
    my (@readers) = @_;
    my (@ancestors) = ($package, $class->ancestors);
    my (@stores) = $class->variable_stores;

    {
        no strict 'refs';
        R:foreach my $reader (@readers) {
            A:foreach my $ancestor (@ancestors) {
                my ($store) = *{$ancestor . '::' . $reader}{HASH};

                if ($store) {
                    my ($name) = "$package\::$reader";
                    my ($method) = *{$name}{CODE};

                    die "Method $reader already exists in $package\n"
                        if ($method);

                    *{$name} = method { $store->{id $self} };
                    next R;
                }
            }

            die "Could not find public store for $reader from $package\n";
        }
    }
}

method writers($class:) {
    my ($package) = Class::get($class);
    my (@writers) = @_;
    my (@ancestors) = ($package, $class->ancestors);
    my (@stores) = $class->variable_stores;

    {
        no strict 'refs';
        W:foreach my $writer (@writers) {
            A:foreach my $ancestor (@ancestors) {
                my ($store) = *{$ancestor . '::' . $writer}{HASH};

                if ($store) {
                    my ($name) = "$package\::set_$writer";
                    my ($method) = *{$name}{CODE};

                    die "Method $writer already exists in $package\n"
                        if ($method);

                    *{$name} = method($value) { $store->{id $self} = $value };
                    next W;
                }
            }

            die "Could not find public store for $writer from $package\n";
        }
    }
}

method accessors($class:) {
    $class->readers(@_);
    $class->writers(@_);
}

method initialize { }
method class { ref($self) || 'Class' }

1;
