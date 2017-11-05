use strict;
use warnings;
use Test::More;
use t::Util;

test('in the main package', <<'END', {'Test::More' => 0.98}, {}, {});
require Test::More; Test::More->VERSION('0.98');
END

test('if block', <<'END', {}, {}, {'Test::More' => 0.98});
if (1) { require Test::More; Test::More->VERSION('0.98'); }
END

done_testing;
