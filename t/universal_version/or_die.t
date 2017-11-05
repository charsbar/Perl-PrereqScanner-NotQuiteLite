use strict;
use warnings;
use Test::More;
use t::Util;

test('eval block or die', <<'END', {}, {'Test::More' => 0.98});
eval { require Test::More; Test::More->VERSION('0.98') } or die;
END

done_testing;
