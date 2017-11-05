use strict;
use warnings;
use Test::More;
use t::Util;

test('if (eval)', <<'END', {}, {'Test::More' => 0});
if ( eval "require 'Test/More.pm';" ) { }
END

done_testing;
