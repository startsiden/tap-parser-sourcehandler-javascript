package TAP::Parser::SourceHandler::JavaScript;
#ABSTRACT: Collection of source handlers for javascript test frameworks
#

use Role::Tiny;

requires '_name';

=method can_handle $source

Called by L<< TAP::Parser >> for each SourceHandler to cast votes on wether they can
handle this source or not.

We only handle files, and by default we will vote for files matching extension
C<< .test.js >>, but this is configurable trought the C<ext> config option.

If you specify a C<folder> option, we will vote 0.8 for any file matching our
extension in that folder, and 0.4 for other files matching our extension.

If you want to handle different types of javascript in one test suite, you can
either have different extensions for each, or you can put them in different folders.

=cut

sub can_handle {
    my ( $class, $source ) = @_;


    my $meta = $source->meta;
    my $config = $source->config_for( $class->_name() );

    return 0 unless $meta->{is_file};

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




1;
