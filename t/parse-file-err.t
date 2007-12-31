#!/usr/bin/perl

use File::Spec::Functions qw(rel2abs splitpath catfile);
use Test::More;
use Test::NoWarnings;
use warnings;
use strict;


my $DIR      = rel2abs((splitpath __FILE__)[1]);
my $ERR_FILE = catfile($DIR, 'parse-file-err.lua');


plan tests => 3;


use_ok("Data::Lua");


{
    my $vars = Data::Lua->parse_file($ERR_FILE);
    is($vars, undef, "parse error");
}
