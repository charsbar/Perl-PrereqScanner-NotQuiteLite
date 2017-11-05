use strict;
use warnings;
use t::scan::Util;

test(<<'TEST'); # perlref
      $sref->$*;  # same as  ${ $sref }
      $aref->@*;  # same as  @{ $aref }
      $aref->$#*; # same as $#{ $aref }
      $href->%*;  # same as  %{ $href }
      $cref->&*;  # same as  &{ $cref }
      $gref->**;  # same as  *{ $gref }
      $gref->*{SCALAR}; # same as *{ $gref }{SCALAR}
      $aref->@[ ... ];  # same as @$aref[ ... ]
      $href->@{ ... };  # same as @$href{ ... }
      $aref->%[ ... ];  # same as %$aref[ ... ]
      $href->%{ ... };  # same as %$href{ ... }
TEST

test(<<'TEST'); # CVLIBRARY/WebDriver-Tiny-0.006/lib/WebDriver/Tiny/Elements.pm
sub append { bless [ shift->@*, map @$_[ 1.. $#$_ ], @_ ] }
sub first  { bless [ $_[0]->@[ 0,  1 ] ] }
sub last   { bless [ $_[0]->@[ 0, -1 ] ] }
sub size   { $#{ $_[0] } }
sub slice  { my ( $drv, @ids ) = shift->@*; bless [ $drv, @ids[@_] ] }
sub split  { my ( $drv, @ids ) = $_[0]->@*; map { bless [ $drv, $_ ] } @ids }
TEST

done_testing;
