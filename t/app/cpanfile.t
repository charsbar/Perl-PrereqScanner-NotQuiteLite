use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";
use Test::More;
use t::Util;

note 'no cpanfile';
test_cpanfile(sub {
  my $tmpdir = shift;
  my $tmpfile = "$tmpdir/MyTest.pm";

  test_file("$tmpdir/MyTest.pm", <<'END');
use strict;
use warnings;
END
}, {}, <<'CPANFILE');
requires 'strict';
requires 'warnings';
CPANFILE

note 'existing cpanfile';
test_cpanfile(sub {
  my $tmpdir = shift;
  my $tmpfile = "$tmpdir/MyTest.pm";

  test_file("$tmpdir/MyTest.pm", <<'END');
use strict;
use warnings;
END

  test_file("$tmpdir/cpanfile", <<'END');
requires 'strict';
requires 'warnings';
END
}, {}, <<'CPANFILE');
requires 'strict';
requires 'warnings';
CPANFILE

note 'cpanfile with extra requirements';
test_cpanfile(sub {
  my $tmpdir = shift;
  my $tmpfile = "$tmpdir/MyTest.pm";

  test_file("$tmpdir/MyTest.pm", <<'END');
use strict;
use warnings;
END

  test_file("$tmpdir/cpanfile", <<'END');
requires 'strict';
requires 'warnings';
requires 'Something::Else';
END
}, {}, <<'CPANFILE');
requires 'Something::Else';
requires 'strict';
requires 'warnings';
CPANFILE

done_testing;
