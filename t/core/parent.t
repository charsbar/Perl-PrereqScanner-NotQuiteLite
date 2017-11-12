use strict;
use warnings;
use Test::More;
use t::Util;

local $t::Util::EVAL = 1;

test('parent singlequotes', <<'END', {parent => 0, Exporter => 0});
use parent 'Exporter';
END

test('parent doublequotes', <<'END', {parent => 0, Exporter => 0});
use parent "Exporter";
END

test('parent qw()', <<'END', {parent => 0, Exporter => 0});
use parent qw(Exporter);
END

test('parent multilined qw()', <<'END', {parent => 0, Exporter => 0});
use parent qw(
  Exporter
);
END

test('parent bareword (only works without strict)', <<'END', {parent => 0, Exporter => 0});
use parent Exporter;
END

test('parent + function', <<'END', {parent => 0});
sub function {}
use parent function();
END

test('parent + ()', <<'END', {parent => 0});
use parent ();
END

test('parent + (bareword)', <<'END', {parent => 0, Carp => 0});
use parent (Carp);
END

done_testing;
