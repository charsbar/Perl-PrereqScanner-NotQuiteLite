use strict;
use warnings;
use Test::More;
use t::scan::Util;

test(<<'TEST'); # ASH/TryCatch-1.003002/t/lib/NoVarName.pm
use TryCatch;

try {
}
catch(Error $) {
    print "Error catched\n";
}
TEST

done_testing;
