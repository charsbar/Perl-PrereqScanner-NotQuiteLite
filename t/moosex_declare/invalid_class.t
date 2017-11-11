use strict;
use warnings;
use Test::More;
use t::Util;

test('invalid class name', <<'END', {'MooseX::Declare' => 0, true => 0, }); # DBR/Dist-Zilla-MintingProfile-MooseXDeclare-0.200/profiles/App/Module.pm
package {{$name}};

use MooseX::Declare;
use true;

#  PODNAME: {{$name}}
# ABSTRACT: Fun with {{$name}}!

class {{$name}} extends MooseX::App::Cmd with MooseX::Log::Log4perl {
  ...
}
END

done_testing;
