use lib 't/lib';
use ThreadsCheck;
use threads;
use strict;
use warnings;
use Test::More;

use Sub::Defer;

my %made;

my $one_defer = defer_sub 'Foo::one' => sub {
  die "remade - wtf" if $made{'Foo::one'};
  $made{'Foo::one'} = sub { 'one' };
};

ok(threads->create(sub {
  my $info = Sub::Defer::defer_info($one_defer);
  my $name = $info && $info->[0] || '[undef]';
  my $ok = $name eq 'Foo::one';
  if (!$ok) {
    print STDERR "#   Bad sub name when undeferring: $name\n";
  }
  return $ok ? 1234 : 0;
})->join == 1234, 'able to retrieve info in thread');

ok(threads->create(sub {
  undefer_sub($one_defer);
  my $ok = $made{'Foo::one'} && $made{'Foo::one'} == \&Foo::one;
  return $ok ? 1234 : 0;
})->join == 1234, 'able to undefer in thread');

done_testing;
