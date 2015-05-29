package Perl::PrereqScanner::NotQuiteLite::Parser::Moose;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  use => {
    'Moose' => 'parse_moose_args',
    'Moo'   => 'parse_moose_args',
    'Mo'    => 'parse_moose_args',
    'Mouse' => 'parse_moose_args',
  },
  no => {
    'Moose' => 'parse_no_moose_args',
    'Moo'   => 'parse_no_moose_args',
    'Mo'    => 'parse_no_moose_args',
    'Mouse' => 'parse_no_moose_args',
  },
}}

sub parse_moose_args {
  my ($class, $c, $used_module, $tokens) = @_;

  $c->register_keyword(
    'extends',
    [$class, 'parse_extends_args', $used_module],
  );
  $c->register_keyword(
    'with',
    [$class, 'parse_with_args', $used_module],
  ) unless $used_module eq 'Mo'; # Mo doesn't support with
}

sub parse_no_moose_args {
  my ($class, $c, $used_module, $tokens) = @_;

  $c->remove_keyword('extends');
  $c->remove_keyword('with') unless $used_module eq 'Mo';
}

sub parse_extends_args { shift->_parse_loader_args(@_) }
sub parse_with_args { shift->_parse_loader_args(@_) }

sub _parse_loader_args {
  my ($class, $c, $used_module, $tokens) = @_;

  while ($tokens->have_token) {
    my @maybe_modules = $tokens->read('strings');
    if (my $tokens_in_between = $tokens->read_between('braces')) {
      while($tokens_in_between->have_token) {
        if ($tokens_in_between->block_depth) {
          $tokens_in_between->next;
          next;
        }
        if ($tokens_in_between->current_is(qw/keyword string/) and
          $tokens_in_between->read_data eq '-version'
        ) {
          $tokens_in_between->next if $tokens_in_between->current_is('comma');
          my $version = $tokens_in_between->read_data;
          if (is_version($version)) {
            my $maybe_module = pop @maybe_modules;
            $c->add($maybe_module => $version);
            last;
          }
        }
        $tokens_in_between->next;
      }
    }
    $c->add($_ => 0) for @maybe_modules;
    last unless $tokens->current_is(qw/whitespace comma/);
    $tokens->next;
  }
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::Moose

=head1 DESCRIPTION

This parser is to deal with modules loaded by C<extends> and/or
C<with> from L<Moose> and its friends.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
