package TAP::Parser::SourceHandler::Buster;
#ABSTRACT: Lets you run tests with buster trough prove

use warnings;
use strict;

use Role::Tiny::With;
with 'TAP::Parser::SourceHandler::JavaScript';

use TAP::Parser::IteratorFactory   ();
use TAP::Parser::Iterator::Process ();

our @ISA = qw( TAP::Parser::SourceHandler );
TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);


sub _name { 'Buster' }

sub make_iterator {
    my ( $class, $source ) = @_;

    my $config = $source->config_for( $class->_name );
    my @command = ( $config->{buster} || (
            -x './node_modules/buster/bin/buster-test'
            ?  './node_modules/buster/bin/buster-test'
            :  './node_modules/buster/bin/buster'
        )
    );
    push @command, qw(
        --reporter tap
        -t 
    );

    my $fn = ref $source->raw ? ${ $source->raw } : $source->raw;

    push @command, $fn;
    return TAP::Parser::Iterator::Process->new( {
            command => \@command,
            merge   => $source->merge,
        }
    );
}

1;


