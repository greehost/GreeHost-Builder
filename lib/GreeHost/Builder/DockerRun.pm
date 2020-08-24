package GreeHost::Builder::DockerRun;
use Moo;
use IPC::Run3;
use Cwd;
use File::Temp;

has config => (
    is       => 'ro',
    required => 1,
);

has system => (
    is       => 'ro',
    required => 1,
);

sub _build {
    my ( $self ) = @_;

    my $script = File::Temp->new();
    print $script join( "\n", @{$self->config->{script}});
    $script->sync;

    my @vols = ( 
        '-v', getcwd . ":/app:rw",
        '-v', $script->filename . ":/script:ro"
    );

    run3([qw( docker run -w /app ), @vols, $self->config->{image}, '/bin/bash', '/script' ]);
}

sub build {
    my ( $class, $config, $system ) = @_;

    return $class->new( config => $config, system => $system )->_build;
}

1;
