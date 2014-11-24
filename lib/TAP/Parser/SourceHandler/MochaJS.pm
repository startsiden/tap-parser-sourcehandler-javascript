package TAP::Parser::SourceHandler::MochaJS;
#ABSTRACT: Lets you run tests with mocha trough prove

use warnings;
use strict;

use TAP::Parser::IteratorFactory   ();
use TAP::Parser::Iterator::Process ();

our @ISA = qw( TAP::Parser::SourceHandler );
TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);

sub can_handle {
    my ( $class, $source ) = @_;


    my $meta = $source->meta;
    my $config = $source->config_for( 'MochaJS' );

    return 0 unless $meta->{is_file};

    # XXX: This should be configurable?
    my $ext = $config->{ext} || '.test.js';
    return 0 unless ($meta->{file}->{basename} =~ m/\Q$ext\E$/);

    if (my $folder = $config->{folder}) {
        $folder = [$folder] unless ref $folder;
        $folder = [ map { qr{^\Q$_\E} } @$folder ];

        my $dir = $meta->{file}->{dir};

        return 0.8 if grep { $dir =~ $_ } @$folder;

    } elsif ($meta->{file}->{basename} =~ m/\Q$ext\E$/) {
        return 0.4;
    }


    return 0;
}

sub make_iterator {
    my ( $class, $source ) = @_;

    my $config = $source->config_for( 'MochaJS' );
    my $timeout = $config->{timeout} // 50_000;
    my @command = ( $config->{mocha} || 'mocha' );
    push @command, qw(
        --reporter tap
        -t 
    ), $timeout;

    my $fn = ref $source->raw ? ${ $source->raw } : $source->raw;

    push @command, $fn;
    return TAP::Parser::Iterator::Process->new( {
            command => \@command,
            merge   => $source->merge,
        }
    );
}

1;

