use strict;
use warnings;
use Test::More;
use t::scan::Util;

test(do { my $code = <<'TEST'; chomp $code; $code });
# comment without eol
TEST

done_testing;
