use strict;
use warnings;
use Test::More;
use t::Util;

test('base singlequotes', <<'END', {mixin => 0, Exporter => 0});
use mixin 'Exporter';
END

done_testing;
