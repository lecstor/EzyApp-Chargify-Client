package EzyApp::Chargify::Role::Client;
use Moose::Role;

use Mojo::UserAgent;


has site_id => (
    is => 'ro',
    isa => 'Str',
);

has api_key => (
    is => 'ro',
    isa => 'Str',
);

has api_host => (
    is => 'ro',
    isa => 'Str',
);

has user_agent => (
    is => 'ro',
    lazy => 1,
    default => sub{
        my ($self) = @_;
        my $ua = Mojo::UserAgent->new;
        return $ua->inactivity_timeout( $self->ua_inactivity_timeout );
    }
);

has ua_inactivity_timeout => (
    is => 'ro',
    isa => 'Num',
    default => 30,
);

has response => (
    is => 'rw',
);

has base_url => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_builder_base_url'
);

has debug_on => (
    is => 'ro',
    isa => 'Num',
    default => 0,
);

sub _builder_base_url{
    my ($self) = @_;
    return sprintf 'https://%s', $self->api_host;
}

sub debug{
    my ($self, $message) = @_;
    return unless $self->debug_on;
    if (ref $message){
        warn Dumper($message);
    } else {
        warn $message;
    }
}

1;
