use strict;
use warnings;
use Test::More;
use t::Util;

test('require pragma', <<'END', {strict => 0, warnings => 0});
require strict;
require warnings;
END

test('require Module', <<'END', {'Test' => 0, 'Test::More' => 0});
require Test;
require Test::More;
END

test('require v-string', <<'END', {perl => 'v5.10.1'});
require v5.10.1;
END

test('require version_number', <<'END', {perl => '5.010001'});
require 5.010001;
END

test('require file', <<'END', {'Test::More' => 0});
my $file = "Test/More.pm";
require "Test/More.pm";
require "cgi-lib.pl";
require $file;
END

test('require Module in if', <<'END', {}, {}, {'Test::More' => 0});
if (1) { require Test::More; }
END

test('require Module in sub', <<'END', {}, {}, {'Test::More' => 0});
sub foo { require Test::More; }
END

test('require Module in sub', <<'END', {'Test::More' => 0});
BEGIN { require Test::More; }
END

done_testing;
