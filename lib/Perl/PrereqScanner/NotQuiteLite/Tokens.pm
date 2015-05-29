package Perl::PrereqScanner::NotQuiteLite::Tokens;

use strict;
use warnings;
use Compiler::Lexer;
use Perl::PrereqScanner::NotQuiteLite::Util;

my %TokenNameMap = (
  use               => {UseDecl => 1},
  require           => {RequireDecl => 1},
  word_list         => {RegList => 1},
  keyword           => {Key => 1},
  method            => {Method => 1},
  semicolon         => {SemiColon => 1},
  open_brace        => {LeftBrace => 1},
  open_bracket      => {LeftBracket => 1},
  open_parenthesis  => {LeftParenthesis => 1},
  close_brace       => {RightBrace => 1},
  close_bracket     => {RightBracket => 1},
  close_parenthesis => {RightParenthesis => 1},
  _pointer          => {Pointer => 1},

  string            => {RawString => 1, String => 1,
                        RegQuote => 1, RegDoubleQuote => 1},
  whitespace        => {WhiteSpace => 1, Comment => 1, Pod => 1},
  comma             => {Comma => 1, Arrow => 1},
  version           => {VersionString => 1, Int => 1, Double => 1},
  parentheses       => {LeftParenthesis => 1,
                        RightParenthesis => 1},
  _used_module      => {UsedName => 1, RequiredName => 1,
                        IfStmt => 1},
  _namespace        => {Namespace => 1, NamespaceResolver => 1},
  _string           => {RawString => 1, String => 1},
  _quotelike_string => {RegQuote => 1, RegDoubleQuote => 1},
  _open_brackets    => {LeftBrace => 1,
                        LeftBracket => 1,
                        LeftParenthesis => 1},
  _close_brackets   => {RightBrace => 1,
                        RightBracket => 1,
                        RightParenthesis => 1},
  _quotelike        => {RegDelim => 1, RegExp => 1},

  # _used_module + _namespace
  bare_module_name  => {UsedName => 1, RequiredName => 1,
                        IfStmt => 1,
                        Namespace => 1, NamespaceResolver => 1},

  # above + keyword + string
  module_name       => {UsedName => 1, RequiredName => 1,
                        IfStmt => 1,
                        Namespace => 1, NamespaceResolver => 1,
                        Key => 1,
                        RawString => 1, String => 1,
                        RegQuote => 1, RegDoubleQuote => 1},

  # version + string
  version_string    => {VersionString => 1, Int => 1, Double => 1,
                        RawString => 1, String => 1,
                        RegQuote => 1, RegDoubleQuote => 1},
);

sub new {
  my ($class, $string) = @_;

  my $tokens;
  if ($string) {
    my $lexer = Compiler::Lexer->new({verbose => 1});
    $tokens = $lexer->tokenize($string);
  }

  $class->new_from_tokens($tokens);
}

sub new_from_tokens {
  my ($self, $tokens) = @_;
  $tokens ||= [];
  bless {
    tokens => $tokens,
    length => scalar @$tokens,
    pos => 0,
    block_depth => 0,
  }, (ref $self || $self);
}

sub have_token {
  my $self = shift;
  my $pos = $self->{pos};
  return if $pos < 0 or $pos >= $self->{length};
  1;
}

sub have_next {
  my $self = shift;
  my $pos = $self->{pos} + 1;
  return if $pos < 0 or $pos >= $self->{length};
  1;
}

sub next {
  my $self = shift;
  my $length = $self->{length} or return;

  my $pos = ++$self->{pos};
  return unless $pos < $length;

  my $token_name = $self->{tokens}[$pos]{name};
  if (exists $TokenNameMap{open_brace}{$token_name}) {
    $self->{block_depth}++
  } elsif (exists $TokenNameMap{close_brace}{$token_name}) {
    $self->{block_depth}-- if $self->{block_depth} > 0;
  }

  # namespace should be checked before other stuff independently
  while(exists $TokenNameMap{_namespace}{$token_name}) {
    # duplication for performance
    $pos = ++$self->{pos};
    return unless $pos < $length;

    $token_name = $self->{tokens}[$pos]{name};
    if (exists $TokenNameMap{open_brace}{$token_name}) {
      $self->{block_depth}++
    } elsif (exists $TokenNameMap{close_brace}{$token_name}) {
      $self->{block_depth}-- if $self->{block_depth} > 0;
    }
  }

  while(exists $TokenNameMap{whitespace}{$token_name} or exists $TokenNameMap{_quotelike}{$token_name}) {
    # duplication for performance
    $pos = ++$self->{pos};
    return unless $pos < $length;

    $token_name = $self->{tokens}[$pos]{name};
    if (exists $TokenNameMap{open_brace}{$token_name}) {
      $self->{block_depth}++
    } elsif (exists $TokenNameMap{close_brace}{$token_name}) {
      $self->{block_depth}-- if $self->{block_depth} > 0;
    }
  }
  1;
}

sub block_depth { $_[0]->{block_depth} }

sub mark {
  my $self = shift;
  $self->{marked} = {
    data => $self->current_data,
    pos => $self->{pos},
    depth => $self->{block_depth},
  };
  $self->next;
  1;
}

sub is_marked { exists $_[0]->{marked} }

sub unmark {
  my $self = shift;
  delete $self->{marked};
  $self->next;
  0;
}

sub marked_data {
  my $self = shift;
  return unless exists $self->{marked};
  return $self->{marked}{data};
}

sub marked_tokens {
  my $self = shift;
  my @tokens;
  if (exists $self->{marked}) {
    my $marked = $self->{marked}{pos};
    my $last = $self->{pos} - 1;
    $last = $self->{length} - 1 unless $last < $self->{length};
    if ($last > $marked) {
      @tokens = @{$self->{tokens}}[$marked .. $last];
    }
  }
  $self->new_from_tokens(\@tokens);
}

sub current_is {
  my ($self, @types) = @_;

  my $pos = $self->{pos};
  return if $pos < 0 or $pos >= $self->{length};
  my $token = $self->{tokens}[$pos];

  my $token_name = $token->{name};
  for my $type (@types) {
    if (exists $TokenNameMap{$type}) {
      return $type if exists $TokenNameMap{$type}{$token_name};
    } elsif ($type eq 'end_of_statement') {
      my $block_depth = $self->{block_depth};
      return $type if !$block_depth and $token_name eq 'SemiColon';
      next unless exists $self->{marked};
      my $marked_depth = $self->{marked}{depth};
      return $type if $block_depth < $marked_depth or ($block_depth == $marked_depth and $token_name eq 'SemiColon');
    } elsif ($type eq 'eval' or $type eq 'no') {
      return $type if $token_name eq 'BuiltinFunc' and $token->{data} eq $type;
    }
  }
  return;
}

sub current {
  my ($self, $type) = @_;
  my $pos = $self->{pos};
  return if $pos < 0 or $pos >= $self->{length};
  return $self->current_data unless $type;

  if ($type eq 'bare_module_name') {
    my $token_name = $self->{tokens}[$pos]{name};
    if (exists $TokenNameMap{_used_module}{$token_name} or
        exists $TokenNameMap{_namespace}{$token_name}
    ) {
      return $self->current_data;
    }
    return;
  } elsif ($type eq 'module_name') {
    my $token_name = $self->{tokens}[$pos]{name};
    if (exists $TokenNameMap{_used_module}{$token_name} or
        exists $TokenNameMap{_namespace}{$token_name} or
        exists $TokenNameMap{keyword}{$token_name} or
        exists $TokenNameMap{string}{$token_name}
    ) {
      return $self->current_data;
    }
    return;
  } elsif ($type eq 'version') {
    my $token_name = $self->{tokens}[$pos]{name};
    if (exists $TokenNameMap{version}{$token_name}) {
       return $self->current_data;
    }
    return;
  } elsif ($type eq 'version_string') {
    my $token_name = $self->{tokens}[$pos]{name};
    if (exists $TokenNameMap{version}{$token_name}) {
       return $self->current_data;
    }
    if (exists $TokenNameMap{string}{$token_name}) {
      my $version = $self->current_data;
      return $version if is_version($version);
    }
    return;
  } elsif ($type eq 'method_caller') {
    my $tmp = $pos - 1;
    return if $tmp < 0;
    return unless exists $TokenNameMap{_pointer}{$self->{tokens}[$tmp]{name}};
    my $module = '';
    while(--$tmp >= 0) {
      my $token = $self->{tokens}[$tmp];
      my $token_name = $token->{name};
      last unless exists $TokenNameMap{keyword}{$token_name} or exists $TokenNameMap{_namespace}{$token_name};
      $module = $token->{data} . $module;
    }
    return $module if is_module_name($module);
    return;
  }
  return $self->current_data;
}

sub current_data {
  my $self = shift;
  my $length = $self->{length} or return;
  my $pos = $self->{pos};
  return if $pos < 0 or $pos >= $length;
  my $token = $self->{tokens}[$pos];
  my $token_name = $token->{name};
  if (exists $TokenNameMap{_quotelike_string}{$token_name}) {
    return unless $pos + 2 < $length;
    return $self->{tokens}[$pos + 2]{data};
  } elsif (exists $TokenNameMap{word_list}{$token_name}) {
    return unless $pos + 2 < $length;
    my ($data) = $self->{tokens}[$pos + 2]{data} =~ /\A\s*(.*)\s*\z/s;
    return split /\s/, $data;
  } elsif (exists $TokenNameMap{_namespace}{$token_name}) {
    my $data = $token->{data};
    my $namespace_pos = $pos;
    while(++$namespace_pos < $length) {
      $token = $self->{tokens}[$namespace_pos];
      last unless exists $TokenNameMap{_namespace}{$token->{name}};
      $data .= $token->{data};
    }
    return $data;
  }
  $token->{data};
}

sub read {
  my ($self, $type) = @_;
  my $length = $self->{length} or return;

  if ($type && $type eq 'strings') {
    my @strings;
    while ($self->{pos} < $length) {
      my $token = $self->{tokens}[$self->{pos}];
      my $token_name = $token->{name};
      if (exists $TokenNameMap{string}{$token_name}) {
        push @strings, $token->{data};
        $self->next;
        next;
      } elsif (exists $TokenNameMap{word_list}{$token_name}) {
        last unless $self->{pos} + 2 < $length;
        my ($data) = $self->{tokens}[$self->{pos} + 2]{data} =~ /\A\s*(.*)\s*\z/s;
        push @strings, split /\s/, $data;
        $self->next;
        next;
      } elsif (exists $TokenNameMap{parentheses}{$token_name} or exists $TokenNameMap{comma}{$token_name}) {
        $self->next;
        next;
      }
      last;
    }
    return @strings;
  }
  my $data = $self->current($type);
  return unless defined $data;
  $self->next;
  $data;
}

sub read_data {
  my $self = shift;
  my $pos = $self->{pos};
  return if $pos < 0 or $pos >= $self->{length};
  my $data = $self->current_data;
  return unless defined $data;
  $self->next;
  $data;
}

sub read_between {
  my ($self, $type) = @_;
  my $length = $self->{length} or return;

  my ($open, $close) =
    ($type eq 'braces') ? ('open_brace', 'close_brace') :
    ($type eq 'brackets') ? ('open_bracket', 'close_bracket') :
    ($type eq 'parentheses') ? ('open_parenthesis', 'close_parenthesis') :
    return;

  my @tokens;
  my $depth = 0;
  my $pos = $self->{pos};
  while($pos < $length) {
    my $token = $self->{tokens}[$pos];
    my $token_name = $token->{name};
    if (exists $TokenNameMap{$open}{$token_name}) {
      next unless $depth++;
    } elsif (exists $TokenNameMap{$close}{$token_name}) {
      $depth-- if $depth > 0;
    }
    last unless $depth;
    push @tokens, $token;
  } continue { $pos++ }
  return unless @tokens;
  $self->{pos} = $pos;
  $self->next;
  $self->new_from_tokens(\@tokens);
}

sub skip_tokens_in_brackets {
  my $self = shift;
  my $depth = 0;
  my $length = $self->{length};
  while($self->{pos} < $length) {
    my $token_name = $self->{tokens}[$self->{pos}]{name};
    if (exists $TokenNameMap{_open_brackets}{$token_name}) {
      $depth++;
    } elsif (exists $TokenNameMap{_close_brackets}{$token_name}) {
      $depth-- if $depth > 0;
    }
    last if !$depth;
    $self->next;
  }
}

sub left {
  my $self = shift;
  $self->new_from_tokens([@{$self->{tokens}}[$self->{pos} .. $self->{length} -1]]);
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Tokens

=head1 DESCRIPTION

This is a wrapper of a list of tokens returned by an XS tokenizer
used in it.

The interface of this module is not completely settled yet.
If you need something to make it easier to write your own parsers,
let me know.

The code is full of repetition for better performance (ugh).

=head1 METHODS

=head2 have_token

returns true if the object points to a token.

=head2 have_next

returns true if the object has another token to process.

=head2 next

moves the internal pointer to a token to the next.

=head2 current_is, current_data, current

  if ($tokens->current_is('module_name')) {
    return $tokens->current('module_name');
  } else {
    return $tokens->current_data;
  }

C<current_is> takes a type name and returns true if the current
token is of that type. C<current> takes a special type name
(C<bare_module_name>, C<module_name>, C<version>, C<version_string>)
and returns an appropriate text if applicable. C<current_data>
is a special form of C<current>. It usually returns a text of the
current token, or a text of another closely-related token (like the
one wrapped in a quote-like operator), or a concatenated texts of
closely-related tokens (like a namespace, which may be split into
several tokens internally).

=head2 read, read_data

  my $module = $tokens->read('module_name');
  my $text = $tokens->read_data;

C<read> is a combination of C<current> and C<next>. It takes a type
name and returns an appropriate text (the same one that would be
returned with C<current>) and moves the pointer to the next (when
the text is actually of the specified type). Likewise, C<read_data>
calls C<current_data> and C<next> internally.

=head2 read_between

  my $new_tokens = $tokens->read_between('braces');

takes a type of bracket (C<parentheses>, C<braces>, C<brackets>) and
returns a ::Tokens object that holds tokens in the brackets, and
moves the pointer to the end of the bracket.

=head2 skip_tokens_in_brackets

If the current token is an open brace/bracket/parenthesis, moves the
pointer to the corresponding close brace/bracket/parenthesis, to
ignore tokens between them.

=head2 block_depth

returns true (actually, a block depth) if a token is in a block.

=head1 METHODS MOSTLY FOR INTERNAL USE

=head2 new

takes a string to tokenize and creates an object.

=head2 new_from_tokens

creates an object from an array reference to tokens.

=head2 mark, unmark, is_marked, marked_data, marked_tokens

  my $is_marked = $tokens->mark
  next unless $tokens->is_marked;
  my $text = $tokens->marked_data;
  my $tokens = $tokens->marked_tokens;
  $tokens->unmark if $is_marked;

C<mark>-related methods are used internally to limit tokens to
process.

=head2 left

returns an object from tokens that are not parsed yet, mainly for
the purpose of debugging.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyclose (c) 2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
