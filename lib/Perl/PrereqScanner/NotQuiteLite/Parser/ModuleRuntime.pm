package Perl::PrereqScanner::NotQuiteLite::Parser::ModuleRuntime;

use strict;
use warnings;
use Perl::PrereqScanner::NotQuiteLite::Util;

sub register { return {
  use => {
    'Module::Runtime' => 'parse_module_runtime_args',
  },
}}

sub parse_module_runtime_args {
  my ($class, $c, $used_module, $raw_tokens) = @_;

  my $tokens = convert_string_tokens($raw_tokens);
  if (is_version($tokens->[0])) {
    $c->add($used_module => shift @$tokens);
  }

  my %known_functions = map {$_ => 1} qw/
    require_module use_module use_package_optimistically
  /;
  for my $token (@$tokens) {
    next if ref $token;

    if ($known_functions{$token}) {
      $c->register_keyword_parser(
        $token,
        [$class, 'parse_'.$token.'_args', $used_module],
      );
    }
  }
  for my $func (keys %known_functions) {
    $c->register_keyword_parser(
      "Module::Runtime::$func",
      [$class, 'parse_'.$func.'_args', $used_module],
    );
  }
}

sub parse_require_module_args {
  my ($class, $c, $used_module, $raw_tokens) = @_;

  my $tokens = convert_string_tokens($raw_tokens);
  shift @$tokens; # function
  my $module = shift @$tokens;
  return unless is_module_name($module);
  $c->add_conditional($module => 0);
}

sub parse_use_module_args {
  my ($class, $c, $used_module, $raw_tokens) = @_;

  my $tokens = convert_string_tokens($raw_tokens);
  shift @$tokens; # function
  my ($module, undef, $version) = @$tokens;
  $version = 0 unless $version and is_version($version);
  $c->add_conditional($module => $version);
}

sub parse_use_package_optimistically_args {
  my ($class, $c, $used_module, $raw_tokens) = @_;

  my $tokens = convert_string_tokens($raw_tokens);
  shift @$tokens; # function
  my ($module, undef, $version) = @$tokens;
  $version = 0 unless $version and is_version($version);
  $c->add_conditional($module => $version);
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Parser::ModuleRuntime

=head1 DESCRIPTION

This parser is to deal with module loading by C<Module::Runtime>.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
