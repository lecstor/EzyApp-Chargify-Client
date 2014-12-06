requires 'Mojo::UserAgent';
requires 'Moose';
requires 'Moose::Role';

on 'test' => sub {
  requires 'Data::Dumper::Perltidy';
  requires 'Devel::Cover';
  requires 'Devel::NYTProf';
  requires 'Test::Exception';
};


