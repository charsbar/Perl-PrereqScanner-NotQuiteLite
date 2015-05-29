package Perl::PrereqScanner::NotQuiteLite::Parser::UniversalVersion;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  method => {
    VERSION => 'parse_version_args',
  },
}}

sub parse_version_args {
  my ($class, $c, $module, $args_tokens, $tokens) = @_;
  return unless $args_tokens;
  my $end_of_statement;
  if ($tokens->current_is('close_brace')) { # end of eval block
    $end_of_statement = 1;
  } else {
    $tokens->next;
    $end_of_statement = 1 if !$tokens->have_next or $tokens->have_token && $tokens->current_is('end_of_statement');
  }
  if ($end_of_statement) {
    if (my $version = $args_tokens->read('version_string')) {
      $c->add($module => $version) if $c->has_added($module);
    }
  }
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::UniversalVersion

=head1 DESCRIPTION

This parser is to deal with a VERSION method called by a	 module.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
