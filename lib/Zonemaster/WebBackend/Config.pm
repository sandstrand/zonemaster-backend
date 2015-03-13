package Zonemaster::WebBackend::Config;
our $VERSION = '1.0.1';

use strict;
use warnings;
use 5.14.2;

use Config::IniFiles;
use File::ShareDir qw[dist_file];

sub _load_config {
    my $cfg;
    my $path;
    if ( -e '/etc/zonemaster/backend_config.ini' ) {
        $path = '/etc/zonemaster/backend_config.ini';
    }
    else {
        $path = dist_file('Zonemaster-WebBackend', "backend_config.ini");
    }
    $cfg = Config::IniFiles->new( -file => $path );

    die "UNABLE TO LOAD $path\n" unless ( $cfg );

    return $cfg;
}

sub BackendDBType {
    my $cfg = _load_config();

    my $result;

    if ( lc( $cfg->val( 'DB', 'engine' ) ) eq 'sqlite' ) {
        $result = 'SQLite';
    }
    elsif ( lc( $cfg->val( 'DB', 'engine' ) ) eq 'postgresql' ) {
        $result = 'PostgreSQL';
    }
    elsif ( lc( $cfg->val( 'DB', 'engine' ) ) eq 'couchdb' ) {
        $result = 'CouchDB';
    }
    elsif ( lc( $cfg->val( 'DB', 'engine' ) ) eq 'mysql' ) {
        $result = 'MySQL';
    }

    return $result;
}

sub DB_user {
    my $cfg = _load_config();

    return $cfg->val( 'DB', 'user' );
}

sub DB_password {
    my $cfg = _load_config();

    return $cfg->val( 'DB', 'password' );
}

sub DB_connection_string {
    my $cfg = _load_config();

    my $db_engine = $_[1] || $cfg->val( 'DB', 'engine' );

    my $result;

    if ( lc( $db_engine ) eq 'sqlite' ) {
        $result = 'DBI:SQLite:dbname=/tmp/zonemaster';
    }
    elsif ( lc( $db_engine ) eq 'postgresql' ) {
        $result =
          'DBI:Pg:database=' . $cfg->val( 'DB', 'database_name' ) . ';host=' . $cfg->val( 'DB', 'database_host' );
    }
    elsif ( lc( $db_engine ) eq 'couchdb' ) {
        $result = 'CouchDB';
    }
    elsif ( lc( $db_engine ) eq 'mysql' ) {
        $result = 'MySQL';
    }

    return $result;
}

sub LogDir {
    my $cfg = _load_config();

    return $cfg->val( 'LOG', 'log_dir' );
}

sub PerlIntereter {
    my $cfg = _load_config();

    return $cfg->val( 'PERL', 'interpreter' );
}

sub PollingInterval {
    my $cfg = _load_config();

    return $cfg->val( 'DB', 'polling_interval' );
}

sub MaxZonemasterExecutionTime {
    my $cfg = _load_config();

    return $cfg->val( 'ZONEMASTER', 'max_zonemaster_execution_time' );
}

sub NumberOfProfessesForFrontendTesting {
    my $cfg = _load_config();

    return $cfg->val( 'ZONEMASTER', 'number_of_professes_for_frontend_testing' );
}

sub NumberOfProfessesForBatchTesting {
    my $cfg = _load_config();

    return $cfg->val( 'ZONEMASTER', 'number_of_professes_for_batch_testing' );
}

1;
