#!/usr/bin/perl

use Test::More;
use Test::NoWarnings;
use warnings;
use strict;


plan tests => 5;


use_ok("Data::Lua");


foreach my $pair (
    [ "s = 'bad"    =>  'parse error'  ],
    [ undef         =>  'undef string' ],
    [ ''            =>  'empty string' ],
) {
    my($in, $test_name) = @$pair;
    my $vars = Data::Lua->parse($in);
    is($vars, undef, $test_name);
}
