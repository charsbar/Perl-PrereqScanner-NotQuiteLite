use strict;
use warnings;
use Test::More;
use t::Util;

test('manual namespace', <<'END', {'MooseX::Declare' => 0, 'Foo::Bar::Baz' => 0, 'Foo::Bar::Fnording' => 0});
use MooseX::Declare;

namespace Foo::Bar;

sub base { __PACKAGE__ }

class ::Baz {
    sub TestPackage::baz { __PACKAGE__ }
}

role ::Fnording {
    sub TestPackage::fnord { __PACKAGE__ }
}

class ::Qux extends ::Baz with ::Fnording {
    sub TestPackage::qux { __PACKAGE__ }
}
END

test('manual namespace', <<'END', {'MooseX::Declare' => 0, 'Foo::Z' => 0, 'Foo::A' => 0, 'Foo::B' => 0, 'Foo::C' => 0});
use MooseX::Declare;

namespace Foo;

role ::Z {
    method foo (Int $x) { $x }
}

role ::C {
    with '::Z';
    around foo (Int $x) { $self->$orig(int($x / 3)) }
}

role ::B {
    with '::C';
    around foo (Int $x) { $self->$orig($x + 2) }
}

role ::A {
    with '::B';
    around foo (Int $x) { $self->$orig($x * 2) }
}

class TEST {
    with '::A';
    around foo (Int $x) { $self->$orig($x + 2) }
}

class AnotherTest {
    with '::Z';
    around foo (Int $x) { $self->$orig($x * 2) }
}
END

done_testing;
