package GreeHost::Builder::Config;
use Moo;
use YAML::XS qw( LoadFile );
use JSONY;
use Try::Tiny;
use File::Slurper qw( read_text );

has config_file => (
    is      => 'ro',
    isa     => sub { -e $_[0] },
    default => sub { 'project.jsony' },
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

    return JSONY->new->load( read_text( $self->config_file ) );
}

sub _build_system {
    my ( $self ) = @_;

    return JSONY->new->load( read_text( $self->system_file ) );
}

# sub _build_system {

# }

# sub _build_data {
#     my ( $self ) = @_;

#     open my $lf, "<", $self->config_file
#         or die "Failed to read config file $self->config_file: $_\n";
#     my $content = do { local $/; <$lf> };
#     close $lf;

#     return JSONY->new->load( $content );
# }

1;
