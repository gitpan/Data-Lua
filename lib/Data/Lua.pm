package Data::Lua;

use Carp qw();
use warnings;
use strict;


our $VERSION = '0.01';


use Inline Lua => q{
    function _lua_loadstring(string)
        local func = loadstring(string)
        return _vars_from_func(func)
    end


    function _lua_loadfile(filename)
        local func = loadfile(filename)
        return _vars_from_func(func)
    end


    function _vars_from_func(func)
        if func == nil then  return nil  end

        local env = {}
        setfenv(func, env)
        func()
        return env
    end
};




sub parse {
    my($class, $string) = @_;
    return undef unless defined $string and length $string;
    return _check(_lua_loadstring($string));
}




sub parse_file {
    my($class, $file) = @_;
    return undef unless defined $file and length $file and -f $file;
    return _check(_lua_loadfile($file));
}




# This subroutine is something of a workaround for a quirk of Inline::Lua.
# If the value being parsed (file or string) sets no variables then the env
# table is empty.  Inline::Lua translates an empty table to an array.  You
# should not otherwise get an array out of a top-level parse of variables, so
# we convert that array to an empty hash.

sub _check {
    my($return) = @_;
    if (ref $return eq 'ARRAY') {
        return {} if not @$return;

        Carp::carp("Parse returned a non-empty arrayref");
        return { 0 => $return };
    }

    return $return;
}




__END__

=head1 NAME

Data::Lua - Parse variables out of Lua code.


=head1 SYNOPSIS

    use Data::Lua;

    my $vars = Data::Lua->parse("foo = 'bar'");
    my $vars = Data::Lua->parse_file('lua.conf');


=head1 DESCRIPTION

This module essentially evals Lua code and returns a hash reference.  The
returned hash reference contains all of the top-level variables, i.e. global
variables assigned outside of any functions.  It currently relies on
Inline::Lua to do the actual code evaluation.

Any Lua code passed to this module should be trusted; there is no checking
done to verify that the code is safe, and any top-level code (outside of
functions) will be run when a parse method is called.


=head1 Methods

=over 4

=item $class->parse($string)

Parses the given string as Lua code and returns a hashref containing all of
the variables defined, including functions.  Returns undef if the string
could not be parsed.


=item $class->parse_file($filename)

Like parse() but parses the given file instead of a string.

=back


=head1 TODO

=over 4

=item *

Provide some means of finding what the specific error was that caused a
parsing problem.  Currently a simple undef is returned, with no indication of
why.

=back


=head1 SEE ALSO

Inline::Lua

Lua (http://www.lua.org)


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007  Michael Fowler.  All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


=head1 AUTHOR

Michael Fowler <mfowler@cpan.org>
