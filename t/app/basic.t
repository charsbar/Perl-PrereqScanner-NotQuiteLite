use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";
use Test::More;
use t::Util;

test_app('basic', sub {
  my $tmpdir = shift;
  my $tmpfile = "$tmpdir/MyTest.pm";

  test_file("$tmpdir/MyTest.pm", <<'END');
use strict;
use warnings;
END
}, { runtime => { requires => { strict => 0, warnings => 0 }}});

test_app('inc', sub {
  my $tmpdir = shift;
  my $tmpfile = "$tmpdir/MyTest.pm";

  test_file("$tmpdir/MyTest.pm", <<'END');
use strict;
use warnings;
use Foo::Bar;
END

  test_file("$tmpdir/inc/Foo/Bar.pm", <<'END');
package Foo::Bar;
1;
END
}, { runtime => { requires => { strict => 0, warnings => 0 }}});

done_testing;
