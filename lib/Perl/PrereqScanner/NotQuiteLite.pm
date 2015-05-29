package Perl::PrereqScanner::NotQuiteLite;

use strict;
use warnings;
use Carp;
use Perl::PrereqScanner::NotQuiteLite::Context;
use Perl::PrereqScanner::NotQuiteLite::Tokens;
use Perl::PrereqScanner::NotQuiteLite::Util;

our $VERSION = '0.01';

our @BUNDLED_PARSERS = qw/
  Aliased Core Moose Plack POE Superclass
  TestMore UniversalVersion
/;
our @DEFAULT_PARSERS = qw/Core Moose/;

sub new {
  my ($class, %args) = @_;

  my %mapping;
  my @parsers = $class->_get_parsers($args{parsers});
  for my $parser (@parsers) {
    eval "require $parser; 1" or next;
    next unless $parser->can('register');
    my $parser_mapping = $parser->register;
    for my $type (qw/use no keyword method/) {
      next unless exists $parser_mapping->{$type};
      for my $name (keys %{$parser_mapping->{$type}}) {
        $mapping{$type}{$name} = [
          $parser,
          $parser_mapping->{$type}{$name},
          (($type eq 'use' or $type eq 'no') ? ($name) : ()),
        ];
      }
    }
  }
  $args{_} = \%mapping;

  bless \%args, $class;
}

sub _get_parsers {
  my ($class, $list) = @_;
  my @parsers;
  my %should_ignore;
  for my $parser (@{$list || [qw/:default/]}) {
    if ($parser eq ':installed') {
      require Module::Find;
      push @parsers, Module::Find::findsubmod("$class\::Parser");
    } elsif ($parser eq ':bundled') {
      push @parsers, map {"$class\::Parser::$_"} @BUNDLED_PARSERS;
    } elsif ($parser eq ':default') {
      push @parsers, map {"$class\::Parser::$_"} @DEFAULT_PARSERS;
    } elsif ($parser =~ s/^\+//) {
      push @parsers, $parser;
    } elsif ($parser =~ s/^\-//) {
      $should_ignore{"$class\::Parser\::$parser"} = 1;
    } elsif ($parser =~ /^$class\::Parser::/) {
      push @parsers, $parser;
    } else {
      push @parsers, "$class\::Parser\::$parser";
    }
  }
  grep {!$should_ignore{$_}} @parsers;
}

sub scan_file {
  my ($self, $file) = @_;
  open my $fh, '<', $file or croak "Can't open $file: $!";
  my $code = do { local $/; <$fh> };
  $self->scan_string($code);
}

sub scan_string {
  my ($self, $string) = @_;

  my $c = Perl::PrereqScanner::NotQuiteLite::Context->new(%$self);

  $self->_scan($c, $string);
}

sub _scan {
  my ($self, $c, $string) = @_;

  my $tokens = Perl::PrereqScanner::NotQuiteLite::Tokens->new($string);

  my $marked;
  my $skips_eval = $c->skips_eval;
  my $in_eval = $c->is_in_eval;
  my $has_keyword_cbs = $c->has_callbacks('keyword');
  my $has_method_cbs = $c->has_callbacks('method');
  while($tokens->have_token) {
    if ($tokens->current_is('eval')) {
      $tokens->next;
      if ($tokens->current_is('open_brace')) {
        $c->enter_eval($tokens->block_depth);
        $tokens->next;
        $in_eval = $c->is_in_eval;
      } elsif ($tokens->current_is('string')) {
        $c->enter_eval(-1);
        $self->_scan($c, $tokens->read_data);
        $c->exit_eval_if_match(-1);
        $in_eval = $c->is_in_eval;
      }
      next;
    }

    if (!$skips_eval or !$in_eval) {

      if (!$marked) {
        if ($tokens->current_is(qw/use require no/)) {
          $marked = $tokens->mark;
          next;
        }

        if ($has_keyword_cbs and
            $tokens->current_is('keyword') and
            $c->has_callback_for('keyword', $tokens->current_data)
        ) {
          $marked = $tokens->mark;
          next;
        }

        if ($has_method_cbs and
            $tokens->current_is('method') and
            $c->has_callback_for('method', $tokens->current_data)
        ) {
          if (my $module = $tokens->current('method_caller')) {
            my $method = $tokens->read_data;
            my $method_args = $tokens->read_between('parentheses');
            $c->run_callback_for('method', $method, $module, $method_args, $tokens);
            $in_eval = $c->is_in_eval;
            $has_keyword_cbs = $c->has_callbacks('keyword');
            $has_method_cbs = $c->has_callbacks('method');
          }
          next;
        }
      }

      if ($marked and $tokens->current_is('end_of_statement')) {
        $self->_parse($c, $tokens->marked_data, $tokens->marked_tokens);
        $marked = $tokens->unmark;
        $in_eval = $c->is_in_eval;
        $has_keyword_cbs = $c->has_callbacks('keyword');
        $has_method_cbs = $c->has_callbacks('method');
        next;
      }
    }

    if ($in_eval and $tokens->current_is('close_brace')) {
      $c->exit_eval_if_match($tokens->block_depth + 1);
      $in_eval = $c->is_in_eval;
    }

    $tokens->next;
  }

  if ($marked) {
    $self->_parse($c, $tokens->marked_data, $tokens->marked_tokens);
  }

  $c;
}

sub _parse {
  my ($self, $c, $keyword, $tokens) = @_;

  $tokens->next; # drop keyword and the following spaces

  if ($keyword eq 'use' or $keyword eq 'no') {
    my $type = $keyword eq 'use' ? 'bare_module_name' : 'module_name';
    my $module = $tokens->read($type);
    if ($module and $c->has_callback_for($keyword, $module)) {
      $c->add($module => 0);
      $c->run_callback_for($keyword, $module, $tokens);
      return;
    }

    my $version = $tokens->read('version');
    if (!$module and $version) {
      return $c->add(perl => $version);
    }

    return $c->add($module => $version);
  }

  if ($keyword eq 'require') {
    my $module = $tokens->read('bare_module_name');
    return $c->add($module => 0) if $module;

    my $version = $tokens->read('version');
    return $c->add(perl => $version) if $version;
  }

  # custom keywords
  return unless $c->has_callback_for('keyword', $keyword);
  $c->run_callback_for('keyword', $keyword, $tokens);
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite - a tool to scan your Perl code for its prerequisites

=head1 SYNOPSIS

  use Perl::PrereqScanner::NotQuiteLite;
  my $scanner = Perl::PrereqScanner::NotQuiteLite->new(
    parsers => [qw/:installed -UniversalVersion/],
    suggests => 1,
  );
  my $context = $scanner->scan_file('path/to/file');
  my $requirements = $context->requires;
  my $suggestions  = $context->suggests; # requirements in evals

=head1 DESCRIPTION

Perl::PrereqScanner::NotQuiteLite is yet another prerequisites
scanner. It passes almost all the scanning tests for
L<Perl::PrereqScanner> and L<Module::ExtractUse> (ie. except for
a few dubious ones), and runs slightly faster than PPI-based
Perl::PrereqScanner. This is partly because
Perl::PrereqScanner::NotQuiteLite uses a different XS lexer
(L<Compiler::Lexer>) in it. However, it
doesn't run as fast as L<Perl::PrereqScanner::Lite> (which uses the
same XS lexer) because Perl::PrereqScanner::NotQuiteLite tries to
hide all the gory details of the lexer to make it easier to write
plugins.

Perl::PrereqScanner::NotQuiteLite also recognizes C<eval>.
Prerequisites in C<eval> are not considered as requirements, but you
can collect them as suggestions.

=head1 METHODS

=head2 new

creates a scanner object. Options are:

=over 4

=item parsers

By default, Perl::PrereqScanner::NotQuiteLite only recognizes
modules loaded directly by C<use>, C<require>, C<no> statements,
plus modules loaded by a few common modules such as C<base>,
C<parent>, C<if> (that are in the Perl core), and by two keywords
exported by L<Moose> family (C<extends> and C<with>).

If you need more, you can pass extra parser names to the scanner, or
C<:installed>, which loads and registers all the installed parsers
under C<Perl::PrereqScanner::NotQuiteLite::Parser> namespace.

You can also pass a project-specific parser (that lies outside the 
C<Perl::PrereqScanner::NotQuiteLite::Parser> namespace) by
prepending C<+> to the name.

  use Perl::PrereqScanner::NotQuiteLite;
  my $scanner = Perl::PrereqScanner::NotQuiteLite->new(
    parsers => [qw/+PrereqParser::For::MyProject/],
  );

If you don't want to load a specific parser for some reason,
prepend C<-> to the parser name.

=item suggests

Perl::PrereqScanner::NotQuiteLite ignores C<use>-like statements in
C<eval> by default. If you set this option to true,
Perl::PrereqScanner::NotQuiteLite also parses statements in C<eval>,
and records requirements as suggestions.

=back

=head2 scan_file

takes a path to a file and returns a ::Context object.

=head2 scan_string

takes a string, scans and returns a ::Context object.

=head1 SEE ALSO

L<Perl::PrereqScanner>, L<Perl::PrereqScanner::Lite>, L<Module::ExtractUse>, L<Compiler::Lexer>

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
