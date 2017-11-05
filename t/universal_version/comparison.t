use strict;
use warnings;
use Test::More;
use t::Util;

# ITUB/Chemistry-Mol-0.37/Mol.pm
test('VERSION < number', <<'END', {Storable => 0});
use Storable;
sub clone {
    my ($self) = @_;
    my $clone = dclone $self;
    $clone->_weaken if Storable->VERSION < 2.14;
    $clone;
}
END

done_testing;
