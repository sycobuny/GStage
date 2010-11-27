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
    my ($package) = ref($class) || $class;
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
    my ($package) = ref($class) || $class;
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

method initialize { }
method class { ref($self) || 'Class' }

1;
