requires 'Compiler::Lexer' => '0.22';
requires 'CPAN::Meta::Prereqs' => '2.113640';
requires 'CPAN::Meta::Requirements' => '2.113640';
requires 'Exporter' => '5.57'; # for import
requires 'Module::Find';

on test => sub {
  requires 'Test::More' => '0.98'; # for sane subtest
  requires 'Test::UseAllModules' => '0.10';
};

on configure => sub {
  requires 'ExtUtils::MakeMaker::CPANfile' => '0.06';
};
