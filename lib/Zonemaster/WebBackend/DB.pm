package Zonemaster::WebBackend::DB;

our $VERSION = '1.0.3';

use Moose::Role;

use 5.14.2;

use Data::Dumper;

requires 'add_api_user_to_db', 'user_exists_in_db', 'user_authorized', 'test_progress', 'test_results',
  'create_new_batch_job', 'create_new_test', 'get_test_params', 'get_test_history';

sub user_exists {
    my ( $self, $user ) = @_;

    die "username not provided to the method user_exists\n" unless ( $user );

    return $self->user_exists_in_db( $user );
}

sub add_api_user {
    my ( $self, $params ) = @_;

    die "username or api_key not provided to the method add_api_user\n"
      unless ( $params->{username} && $params->{api_key} );

    die "User already exists\n" if ( $self->user_exists( $params->{username} ) );

    my $result = $self->add_api_user_to_db( $params );

    die "add_api_user_to_db not successfull" unless ( $result );

    return $result;
}

no Moose::Role;

1;
