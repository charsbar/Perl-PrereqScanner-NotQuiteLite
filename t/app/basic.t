use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";
use Test::More;
use t::Util;

test_app('.pm file in the root', sub {
  my $tmpdir = shift;

  test_file("$tmpdir/MyTest.pm", <<'END');
use strict;
use warnings;
END
}, { runtime => { requires => { strict => 0, warnings => 0 }}});

test_app('.pm file under lib', sub {
  my $tmpdir = shift;

  test_file("$tmpdir/lib/MyTest.pm", <<'END');
use strict;
use warnings;
END
}, { runtime => { requires => { strict => 0, warnings => 0 }}});

test_app('inc', sub {
  my $tmpdir = shift;

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
