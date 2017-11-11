use strict;
use warnings;
use Test::More;
use t::Util;

local $t::Util::EVAL = 1;

test('base singlequotes', <<'END', {base => 0, Exporter => 0});
use base 'Exporter';
END

test('base doublequotes', <<'END', {base => 0, Exporter => 0});
use base "Exporter";
END

test('base qw()', <<'END', {base => 0, Exporter => 0});
use base qw(Exporter);
END

test('base multilined qw()', <<'END', {base => 0, Exporter => 0});
use base qw(
  Exporter
);
END

test('base bareword (only works without strict)', <<'END', {base => 0, Exporter => 0});
use base Exporter;
END

test('base + function', <<'END', {base => 0});
sub function {}
use base function();
END

test('base + ()', <<'END', {base => 0});
use base ();
END

done_testing;
