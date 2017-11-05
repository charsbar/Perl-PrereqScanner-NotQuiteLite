use strict;
use warnings;
use Test::More;
use t::Util;

# PEVANS/Scalar-List-Utils-1.49/lib/Scalar/Util.pm
test('variable', <<'END', {'List::Util' => 0});
use List::Util;
List::Util->VERSION( $VERSION );
END

# CJM/HTML-Tree-5.03/lib/HTML/TreeBuilder.pm
test('numerical version', <<'END', {'LWP::UserAgent' => '5.815'});
use LWP::UserAgent;
LWP::UserAgent->VERSION( 5.815 );
END

# LEONT/Dist-Zilla-Plugin-PPPort-0.007/lib/Dist/Zilla/Plugin/PPPort.pm
test('return value', <<'END', {'Devel::PPPort' => 0});
use Devel::PPPort;
Devel::PPPort->VERSION($self->version);
END

done_testing;
