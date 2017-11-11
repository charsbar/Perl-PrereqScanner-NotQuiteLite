use strict;
use warnings;
use Test::More;
use t::Util;

test('fqfn', <<'END', {}, {'Win32::Console::ANSI' => 0});
BEGIN {
    if ($^O eq 'MSWin32') {
        Class::Load::try_load_class('Win32::Console::ANSI');
    }
};
END

done_testing;
