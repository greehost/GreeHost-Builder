package GreeHost::Builder::Config;
use Moo;
use YAML::XS qw( LoadFile );
use JSONY;
use JSON::MaybeXS qw( decode_json );
use Try::Tiny;
use File::Slurper qw( read_text );
use IPC::Run3;

has config_file => (
    is      => 'ro',
    isa     => sub { -e $_[0] },
    default => sub { './.greehost.json' },
);

has system_file => (
    is      => 'ro',
    isa     => sub { -e $_[0] },
    default => sub { '/etc/greehost.conf' },
);

has data => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_data',
);

has system => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_system',
);

sub _build_data {
    my ( $self ) = @_;

    run3([qw( greehost-builder-config-reader )]);
    return decode_json( read_text( $self->config_file ) );
}

sub _build_system {
    my ( $self ) = @_;

    return JSONY->new->load( read_text( $self->system_file ) );
}

1;
