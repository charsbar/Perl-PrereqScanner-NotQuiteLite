package Perl::PrereqScanner::NotQuiteLite::Parser::Plack;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  use => {
    'Plack::Builder' => 'parse_plack_builder_args',
  },
}}

sub parse_plack_builder_args {
  my ($class, $c, $used_module, $tokens) = @_;

  # TODO: support add_middleware(_if) methods?

  $c->register_keyword(
    'enable',
    [$class, 'parse_enable_args', $used_module],
  );
  $c->register_keyword(
    'enable_if',
    [$class, 'parse_enable_if_args', $used_module],
  );
}

sub parse_enable_args {
  my ($class, $c, $used_module, $tokens) = @_;

  my $module = $tokens->read('module_name') or return;
  if ($module =~ s/^\+//) {
    $c->add($module => 0);
  } else {
    $c->add("Plack::Middleware::".$module => 0);
  }
}

sub parse_enable_if_args {
  my ($class, $c, $used_module, $tokens) = @_;

  while($tokens->have_token) {
    $tokens->skip_tokens_in_brackets; # to ignore commas in brackets
    last if $tokens->current_is(qw/comma close_brace/);
    $tokens->next;
  }
  $tokens->next if $tokens->current_is(qw/close_brace/);
  $tokens->next if $tokens->current_is(qw/comma/);

  my $module = $tokens->read('module_name') or return;
  if ($module =~ s/^\+//) {
    $c->add($module => 0);
  } else {
    $c->add("Plack::Middleware::".$module => 0);
  }
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::Plack

=head1 DESCRIPTION

This parser is to deal with Plack middlewares loaded by L<Plack::Builder>.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
