use strict;
use warnings;
use Test::More;
use t::Util;

test('if (eval)', <<'END', {}, {'Test::More' => 0});
if ( eval "require 'Test/More.pm';" ) { }
END

test('eval()', <<'END', {}, {'Test::More' => 0});
eval('use Test::More');
END

test('eval{"string"}', <<'END', {}, {});
eval{'use Test::More'};
END

done_testing;
