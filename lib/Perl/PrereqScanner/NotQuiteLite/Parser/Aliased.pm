package Perl::PrereqScanner::NotQuiteLite::Parser::Aliased;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  use => {
    aliased => 'parse_aliased_args',
  },
}}

sub parse_aliased_args {
  my ($class, $c, $used_module, $tokens) = @_;
  if (my $version = $tokens->read('version')) {
    $c->add($used_module => $version);
  }
  my $module = $tokens->read('module_name') or return;
  $c->add($module => 0);

  # TODO: support alias keyword?
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::Aliased

=head1 DESCRIPTION

This parser is to deal with a module loaded (aliased) by L<aliased>.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
