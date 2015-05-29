package Perl::PrereqScanner::NotQuiteLite::Parser::Core;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  use => {
    if => 'parse_if_args',
    base => 'parse_base_args',
    parent => 'parse_parent_args',
  },
}}

sub parse_if_args {
  my ($class, $c, $used_module, $tokens) = @_;
  while($tokens->have_token) {
    $tokens->skip_tokens_in_brackets; # to ignore commas in brackets
    last if $tokens->current_is('comma');
    $tokens->next;
  }
  $tokens->next if $tokens->current_is('comma');

  my $module = $tokens->read('module_name') or return;
  $c->add($module => 0);
}

sub parse_base_args {
  my ($class, $c, $used_module, $tokens) = @_;
  if (my $version = $tokens->read('version')) {
    $c->add($used_module => $version);
  }
  $c->add($_ => 0) for $tokens->read('strings');
}

sub parse_parent_args {
  my ($class, $c, $used_module, $tokens) = @_;
  if (my $version = $tokens->read('version')) {
    $c->add($used_module => $version);
  }
  my @maybe_modules = $tokens->read('strings');
  for my $maybe_module (@maybe_modules) {
    last if $maybe_module eq '-norequire';
    $c->add($maybe_module => 0);
  }
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::Core

=head1 DESCRIPTION

This parser is to deal with module inheritance by C<base> and
C<parent> modules, and conditional loading by C<if> module.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
