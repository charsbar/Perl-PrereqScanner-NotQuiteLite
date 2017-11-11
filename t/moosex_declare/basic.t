use strict;
use warnings;
use Test::More;
use t::Util;

test('Foo in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0});
use MooseX::Declare;

class Foo {
    has 'affe' => (
        is  => 'ro',
        isa => 'Str',
    );

    method foo ($x) { $x }

    method inner { 23 }

    method bar ($moo) { "outer(${moo})-" . inner() }

    class ::Bar is mutable {
        method bar { blessed($_[0]) ? 0 : 1 }
    }

    class ::Baz {
        method baz {}
    }
}
END

test('Role in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0});
use MooseX::Declare;

role Role {
    requires 'required_thing';
    method role_method {}
}
END

test('Moo::Kooh in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0, Foo => 0, Role => 0});
use MooseX::Declare;

class Moo::Kooh {
    extends 'Foo';

    around foo ($x) { $x + 1 }

    augment bar ($moo) { "inner(${moo})" }

    method kooh {}
    method required_thing {}

    with 'Role';
}
END

test('Corge in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0, 'Foo::Baz' => 0, Role => 0});
use MooseX::Declare;

class Corge extends Foo::Baz with Role {
    method corge {}
    method required_thing {}
}
END

test('Quux in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0, 'Corge' => 0});
use MooseX::Declare;

class Quux extends Corge {
    has 'x' => (
        is  => 'ro',
        isa => 'Int',
    );

    method quux {}
}
END

test('SecondRole in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0});
use MooseX::Declare;

role SecondRole {}
END

test('SecondRole in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0, 'Role' => 0, 'SecondRole' => 0});
use MooseX::Declare;

class MultiRole with Role with SecondRole {
    method required_thing {}
}
END

test('SecondRole in t/lib/Foo.pm', <<'END', {'MooseX::Declare' => 0, 'Role' => 0, 'SecondRole' => 0});
use MooseX::Declare;

class MultiRole2 with (Role, SecondRole) {
    method required_thing {}
}
END

done_testing;
