use strict;
use warnings;
use 5.14.2;

use Test::More;    # see done_testing()

my $can_use_threads = eval 'use threads; 1';
my $can_use_mysql = eval 'use DBD::mysql; 1';

if ( not $can_use_threads ) {
    plan skip_all => 'No threads in this perl.';
}
elsif ( not $can_use_mysql) {
    plan skip_all => 'Could not load DBD::mysql';
}
else {
    # Require Zonemaster::WebBackend::Engine.pm test
    require_ok( 'Zonemaster::WebBackend::Engine' );

    #require Zonemaster::WebBackend::Engine;

    # Create Zonemaster::WebBackend::Engine object
    my $engine = Zonemaster::WebBackend::Engine->new( { db => 'Zonemaster::WebBackend::DB::MySQL' } );
    isa_ok( $engine, 'Zonemaster::WebBackend::Engine' );

    # create a new memory MySQL database
    ok( $engine->{db}->create_db() );

    # add test user
    ok( $engine->add_api_user( { username => "zonemaster_test", api_key => "zonemaster_test's api key" } ) == 1 );
    ok(
        scalar(
            $engine->{db}->dbh->selectrow_array( q/SELECT * FROM users WHERE user_info like '%zonemaster_test%'/ )
        ) == 1
    );

    # add a new test to the db
    my $frontend_params_1 = {
        client_id      => 'Zonemaster CGI/Dancer/node.js',    # free string
        client_version => '1.0',                              # free version like string

        domain           => 'afnic.fr',                       # content of the domain text field
        advanced_options => 1,                                # 0 or 1, is the advanced options checkbox checked
        ipv4             => 1,                                # 0 or 1, is the ipv4 checkbox checked
        ipv6             => 1,                                # 0 or 1, is the ipv6 checkbox checked
        test_profile     => 'test_profile_1',                 # the id if the Test profile listbox
        nameservers      => [                                 # list of the namaserves up to 32
            { ns => 'ns1.nic.fr', ip => '1.2.3.4' },       # key values pairs representing nameserver => namesterver_ip
            { ns => 'ns2.nic.fr', ip => '192.134.4.1' },
        ],
        ds_digest_pairs => [                               # list of DS/Digest pairs up to 32
            { 'ds1' => 'ds-test1' },                       # key values pairs representing ds => digest
            { 'ds2' => 'digest2' },
        ],
    };
    ok( $engine->start_domain_test( $frontend_params_1 ) == 1 );
    ok( scalar( $engine->{db}->dbh->selectrow_array( q/SELECT id FROM test_results WHERE id=1/ ) ) == 1 );

    # test test_progress API
    ok( $engine->test_progress( 1 ) == 0 );

    require_ok( 'Zonemaster::WebBackend::Runner' );
    threads->create(
        sub { Zonemaster::WebBackend::Runner->new( { db => 'Zonemaster::WebBackend::DB::MySQL' } )->run( 1 ); } )
      ->detach();

    sleep( 5 );
    ok( $engine->test_progress( 1 ) > 0 );

    foreach my $i ( 1 .. 12 ) {
        sleep( 5 );
        my $progress = $engine->test_progress( 1 );
        print STDERR "pregress: $progress\n";
        last if ( $progress == 100 );
    }
    ok( $engine->test_progress( 1 ) == 100 );
    my $test_results = $engine->get_test_results( { id => 1, language => 'fr-FR' } );
    ok( defined $test_results->{id} );
    ok( defined $test_results->{params} );
    ok( defined $test_results->{creation_time} );
    ok( defined $test_results->{results} );
    ok( scalar( @{ $test_results->{results} } ) > 1 );

    my $frontend_params_2 = {
        client_id      => 'Zonemaster CGI/Dancer/node.js',    # free string
        client_version => '1.0',                              # free version like string

        domain           => 'afnic.fr',                       # content of the domain text field
        advanced_options => 1,                                # 0 or 1, is the advanced options checkbox checked
        ipv4             => 1,                                # 0 or 1, is the ipv4 checkbox checked
        ipv6             => 1,                                # 0 or 1, is the ipv6 checkbox checked
        test_profile     => 'test_profile_1',                 # the id if the Test profile listbox
        nameservers      => [                                 # list of the namaserves up to 32
            { ns => 'ns1.nic.fr', ip => '1.2.3.4' },       # key values pairs representing nameserver => namesterver_ip
            { ns => 'ns2.nic.fr', ip => '192.134.4.1' },
        ],
        ds_digest_pairs => [                               # list of DS/Digest pairs up to 32
            { 'ds1' => 'ds-test2' },                       # key values pairs representing ds => digest
            { 'ds2' => 'digest2' },
        ],
    };
    ok( $engine->start_domain_test( $frontend_params_2 ) == 2 );
    ok( scalar( $engine->{db}->dbh->selectrow_array( q/SELECT id FROM test_results WHERE id=2/ ) ) == 2 );

    # test test_progress API
    ok( $engine->test_progress( 2 ) == 0 );

    require_ok( 'Zonemaster::WebBackend::Runner' );
    threads->create(
        sub { Zonemaster::WebBackend::Runner->new( { db => 'Zonemaster::WebBackend::DB::MySQL' } )->run( 2 ); } )
      ->detach();

    sleep( 5 );
    ok( $engine->test_progress( 2 ) > 0 );

    foreach my $i ( 1 .. 12 ) {
        sleep( 5 );
        my $progress = $engine->test_progress( 2 );
        print STDERR "pregress: $progress\n";
        last if ( $progress == 100 );
    }
    ok( $engine->test_progress( 2 ) == 100 );
    $test_results = $engine->get_test_results( { id => 1, language => 'fr-FR' } );
    ok( defined $test_results->{id} );
    ok( defined $test_results->{params} );
    ok( defined $test_results->{creation_time} );
    ok( defined $test_results->{results} );
    ok( scalar( @{ $test_results->{results} } ) > 1 );

    my $frontend_params_3 = {
        client_id      => 'Zonemaster CGI/Dancer/node.js',    # free string
        client_version => '1.0',                              # free version like string

        domain           => 'nic.fr',                         # content of the domain text field
        advanced_options => 1,                                # 0 or 1, is the advanced options checkbox checked
        ipv4             => 1,                                # 0 or 1, is the ipv4 checkbox checked
        ipv6             => 1,                                # 0 or 1, is the ipv6 checkbox checked
        test_profile     => 'test_profile_1',                 # the id if the Test profile listbox
        nameservers      => [                                 # list of the namaserves up to 32
            { ns => 'ns1.nic.fr', ip => '1.2.3.4' },       # key values pairs representing nameserver => namesterver_ip
            { ns => 'ns2.nic.fr', ip => '192.134.4.1' },
        ],
        ds_digest_pairs => [                               # list of DS/Digest pairs up to 32
            { 'ds1' => 'ds-test1' },                       # key values pairs representing ds => digest
            { 'ds2' => 'digest2' },
        ],
    };
    ok( $engine->start_domain_test( $frontend_params_3 ) == 3 );
    ok( scalar( $engine->{db}->dbh->selectrow_array( q/SELECT id FROM test_results WHERE id=3/ ) ) == 3 );

    # test test_progress API
    ok( $engine->test_progress( 3 ) == 0 );

    require_ok( 'Zonemaster::WebBackend::Runner' );
    threads->create(
        sub { Zonemaster::WebBackend::Runner->new( { db => 'Zonemaster::WebBackend::DB::MySQL' } )->run( 3 ); } )
      ->detach();

    sleep( 5 );
    ok( $engine->test_progress( 3 ) > 0 );

    foreach my $i ( 1 .. 20 ) {
        sleep( 5 );
        my $progress = $engine->test_progress( 3 );
        print STDERR "pregress: $progress\n";
        last if ( $progress == 100 );
    }
    ok( $engine->test_progress( 3 ) == 100 );
    $test_results = $engine->get_test_results( { id => 1, language => 'fr-FR' } );
    ok( defined $test_results->{id} );
    ok( defined $test_results->{params} );
    ok( defined $test_results->{creation_time} );
    ok( defined $test_results->{results} );
    ok( scalar( @{ $test_results->{results} } ) > 1 );

    my $offset = 0;
    my $limit  = 10;
    my $test_history =
      $engine->get_test_history( { frontend_params => $frontend_params_1, offset => $offset, limit => $limit } );
    print STDERR Dumper( $test_history );
    ok( scalar( @$test_history ) == 2 );
    ok( $test_history->[0]->{id} == 1 || $test_history->[1]->{id} == 1 );
    ok( $test_history->[0]->{id} == 2 || $test_history->[1]->{id} == 2 );

    done_testing();
}
