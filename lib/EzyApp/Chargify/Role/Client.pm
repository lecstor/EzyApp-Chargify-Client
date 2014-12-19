package EzyApp::Chargify::Role::Client;
use Moose::Role;

use Mojo::UserAgent;
use Data::Dumper 'Dumper';

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
    is => 'rw',
    isa => 'Num',
    default => 0,
);

has last_request => ( is => 'rw', isa => 'ArrayRef' );


sub _builder_base_url{
    my ($self) = @_;
    return sprintf 'https://%s', $self->api_host;
}

=item _request

  $ua->_request('get', $url);
  $ua->_request('post', $url, { form => { a => 'b' } });
  $ua->_request('post', $url, { json => { a => 'b' } });

=cut

sub _request{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($method, $url, $payload) = @_;

  my @args = ($url);
  push(@args, %$payload) if $payload;

  $self->last_request([$method, $url, $payload]);

  if ($callback){
    $self->user_agent->$method(@args, sub{
      my ($ua, $tx) = @_;
      $callback->($tx->error, $tx->res->json());
    });
  } else {
    my $tx = $self->user_agent->$method(@args);
    my $res = $tx->res;
    if (my $err = $tx->error){
      die "$err->{code} $err->{message}\n" if $err->{code};
      die "Connection error: $err->{message}\n";
    } else {
      return $res->json();
    }
  }
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
