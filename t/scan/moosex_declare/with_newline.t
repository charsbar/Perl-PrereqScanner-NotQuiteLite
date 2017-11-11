use strict;
use warnings;
use Test::More;
use t::scan::Util;

test(<<'END');
use MooseX::Declare;

class dongs
{
}

class mtfnpy extends dongs
{
}
END

done_testing;
