package Perl::PrereqScanner::NotQuiteLite::Parser::MojoBase;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  use => {
    'Mojo::Base' => 'parse_mojo_base_args',
  },
}}

sub parse_mojo_base_args {
  my ($class, $c, $used_module, $raw_tokens) = @_;

  my $tokens = convert_string_tokens($raw_tokens);
  if (is_version($tokens->[0])) {
    $c->add($used_module => shift @$tokens);
  }
  my $module = $tokens->[0];
  if (ref $module) {
    $module = $module->[0];
  }
  if (is_module_name($module)) {
    $module =~ s|'|::|g;
    $c->add($module => 0);
  }
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::MojoBase

=head1 DESCRIPTION

This parser is to deal with module inheritance by C<Mojo::Base>.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
