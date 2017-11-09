use strict;
use warnings;
use Test::More;
use t::Util;

# from Catalyst's pod
test('qw', <<'END', {Catalyst => 0, 'Catalyst::Plugin::My::Module' => 0, 'Fully::Qualified::Plugin::Name' => 0});
use Catalyst qw/
        My::Module
        +Fully::Qualified::Plugin::Name
    /;
END

# GSHANK/HTML-FormHandler-Model-DBIC-0.29/t/lib/BookDB.pm
test('-debug', <<'END', {Catalyst => 0, 'Catalyst::Plugin::Static::Simple' => 0});
use Catalyst ('-Debug',
              'Static::Simple',
);
END

done_testing;
