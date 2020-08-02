package GreeHost::Builder::StaticServ;
use Moo;
use Text::Xslate;
use File::Find;
use File::Temp;
use IPC::Run3;
use Object::Remote;

# TODO:
#  - [ ] 
#

has config => (
    is       => 'ro',
    required => 1,
);

has system => (
    is       => 'ro',
    required => 1,
);

my $nginx_template =<<"EOF";
server {
    server_name [% \$domain %];
    listen 80;

%% if \$args.use_ssl {
    listen 443 ssl;
    ssl_certificate      /etc/staticserv/ssl/[% \$domain %]-fullchain.pem;
    ssl_certificate_key  /etc/staticserv/ssl/[% \$domain %]-privkey.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;
%% }

    root /var/www/[% \$domain %];
    index index.html index.htm index.md index.txt;
}
EOF

sub generate_nginx_domain_config {
    my ( $self ) = @_;

    return Text::Xslate->new(
        syntax => 'Metakolon'
    )->render_string($nginx_template, $self->config);
}

sub _build {
    my ( $self ) = @_;

    # Create a temp directory that we'll use for the StaticServ payload.
    my $dir = File::Temp->newdir( CLEANUP => 1 );

    # Stick a webroot.tgz file into this directory, containing the user's webroot.
    run3( [ 'tar', '-C', $self->config->{args}{root}, '-czf', "$dir/webroot.tgz", '.' ] );

    # Generate the config file and stick it the directory.
    my $config_contents = $self->generate_nginx_domain_config;
    open my $sf, ">", "$dir/" . $self->config->{domain} . ".conf"
        or die "Failed to open $dir/$self->config->{domain} for writing: $!";
    print $sf $config_contents;
    close $sf;

    return $self->deploy($dir);
}

sub deploy {
    my ( $self, $directory ) = @_;

    foreach my $host ( @{ $self->system->{staticserv_targets} } ) {
        my $conn = Object::Remote->connect( $host );

        # Create Remote Directory
        my $rdir = File::Temp->can::on( $conn, 'tempdir' )->();

        # Push our directory over into that temporary one.
        run3([ qw( rsync -a ), "$directory/", "$host:$rdir" ]);

        # Trigger the remote-side to ingest the folder
        GreeHost::StaticServ->can::on( $conn, 'install_domain' )->( $rdir );
    }
}

sub build {
    my ( $class, $config, $system ) = @_;

    return $class->new( config => $config, system => $system )->_build;
}

1;
