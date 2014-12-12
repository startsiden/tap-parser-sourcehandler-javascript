package TAP::Parser::SourceHandler::MochaJS;
#ABSTRACT: Lets you run tests with mocha trough prove

use warnings;
use strict;

use Role::Tiny::With;

with 'TAP::Parser::SourceHandler::JavaScript';

use TAP::Parser::IteratorFactory   ();
use TAP::Parser::Iterator::Process ();

our @ISA = qw( TAP::Parser::SourceHandler );
TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);

sub _name { 'MochaJS' }

sub make_iterator {
    my ( $class, $source ) = @_;

    my $config = $source->config_for( $class->_name );
    my $timeout = $config->{timeout} // 50_000;
    # Extra args for the mocha tester, for instance to compile coffeescript
    my $extra = $config->{extra} || '';
    my @command = ( $config->{mocha} || 'mocha' );
    push @command, qw(
        --reporter tap
        -t 
    ), $timeout, split(/\s+/, $extra);

    my $fn = ref $source->raw ? ${ $source->raw } : $source->raw;

    push @command, $fn;
    return TAP::Parser::Iterator::Process->new( {
            command => \@command,
            merge   => $source->merge,
        }
    );
}

1;

