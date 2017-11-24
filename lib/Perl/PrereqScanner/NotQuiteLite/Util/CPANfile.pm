package Perl::PrereqScanner::NotQuiteLite::Util::CPANfile;

use strict;
use warnings;
use parent 'Module::CPANfile';

sub load_and_merge {
  my ($class, $file, $prereqs) = @_;

  $prereqs = $prereqs->as_string_hash unless ref $prereqs eq 'HASH';

  my $self;
  if (-f $file) {
    $self = $class->load($file);
    $self->_add_prereqs($prereqs);
  } else {
    $self = $class->from_prereqs($prereqs);
  }

  $self;
}

sub _add_prereqs {
  my ($self, $prereqs) = @_;
  $prereqs = $prereqs->as_string_hash unless ref $prereqs eq 'HASH';

  for my $phase (keys %$prereqs) {
    for my $type (keys %{$prereqs->{$phase}}) {
      while (my($module, $requirement) = each %{$prereqs->{$phase}{$type}}) {
        $self->{_prereqs}->add_prereq(
          phase => $phase,
          type  => $type,
          module => $module,
          requirement => Module::CPANfile::Requirement->new(name => $module, version => $requirement),
        );
      }
    }
  }
}

sub to_string {
  my ($self, $include_empty) = @_;

  my $mirrors = $self->mirrors;
  my $prereqs = $self->prereq_specs;

  my $code = '';
  $code .= $self->_dump_mirrors($mirrors);
  $code .= $self->_dump_prereqs($prereqs, $include_empty);

  for my $feature ($self->features) {
    $code .= sprintf "feature %s, %s => sub {\n", Module::CPANfile::_dump($feature->{identifier}), Module::CPANfile::_dump($feature->{description});
    # See https://github.com/miyagawa/cpanfile/pull/32
    $code .= $self->_dump_prereqs($feature->{prereqs}->as_string_hash, $include_empty, 4);
    $code .= "};\n\n"; # ALSO TWEAKED
  }

  $code =~ s/\n+$/\n/s;
  $code;
}

sub _dump_prereqs {
  my($self, $prereqs, $include_empty, $base_indent) = @_;

  my $code = '';
  my @x_phases = sort grep {/^x_/i} keys %$prereqs; # TWEAKED
  for my $phase (qw(runtime configure build test develop), @x_phases) {
    my $indent = $phase eq 'runtime' ? '' : '    ';
    $indent = (' ' x ($base_indent || 0)) . $indent;

    my($phase_code, $requirements);
    $phase_code .= "on $phase => sub {\n" unless $phase eq 'runtime';

    my @x_types = sort grep {/^x_/i} keys %{$prereqs->{$phase}}; # TWEAKED
    for my $type (qw(requires recommends suggests conflicts), @x_types) {
      for my $mod (sort keys %{$prereqs->{$phase}{$type}}) {
        my $ver = $prereqs->{$phase}{$type}{$mod};
        $phase_code .= $ver eq '0'
          ? "${indent}$type '$mod';\n"
          : "${indent}$type '$mod', '$ver';\n";
        $requirements++;
      }
    }

    $phase_code .= "\n" unless $requirements;
    $phase_code .= "};\n" unless $phase eq 'runtime';

    $code .= $phase_code . "\n" if $requirements or $include_empty;
  }

  $code =~ s/\n+$/\n/s;
  $code;
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::PrereqScanner::NotQuiteLite::Util::CPANfile

=head1 SYNOPSIS

=head1 DESCRIPTION

This is a wrapper of L<Module::CPANfile>.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
