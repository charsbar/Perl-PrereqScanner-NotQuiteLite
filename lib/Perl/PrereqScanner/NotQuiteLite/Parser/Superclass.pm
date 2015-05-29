package Perl::PrereqScanner::NotQuiteLite::Parser::Superclass;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  use => {
    superclass => 'parse_superclass_args',
  },
}}

sub parse_superclass_args {
  my ($class, $c, $used_module, $tokens) = @_;
  if (my $version = $tokens->read('version')) {
    $c->add($used_module => $version);
  }
  while($tokens->have_token) {
    my @maybe_modules = $tokens->read('strings');
    last if grep {$_ eq '-norequire'} @maybe_modules;
    last unless @maybe_modules;
    if (my $version = $tokens->read('version')) {
      my $maybe_module = pop @maybe_modules;
      $c->add($maybe_module => $version);
    }
    my $version;
    while(my $maybe_module = pop @maybe_modules) {
      if (!is_module_name($maybe_module)) {
        $version = is_version($maybe_module) ? $maybe_module : 0;
        next;
      }
      $c->add($maybe_module => $version || 0);
      $version = 0;
    }
    $tokens->next;
  }
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::Superclass

=head1 DESCRIPTION

This parser is to deal with module inheritance managed by
L<superclass>.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
