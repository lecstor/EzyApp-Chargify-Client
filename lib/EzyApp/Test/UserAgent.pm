package EzyApp::Test::UserAgent::Res;
use Moose;

has json => (
  is => 'ro', isa => 'Maybe[HashRef|ArrayRef]',
  default => sub{ { _req => {} } }
);

no Moose;
__PACKAGE__->meta->make_immutable;



package EzyApp::Test::UserAgent::TX;
use Moose;

has error => (
  is => 'ro', isa => 'Maybe[HashRef]',
  # default => sub {
  #   { code => '500', message => 'Test Server Error' }
  # }
);

has res => (
  is => 'ro', isa => 'Object',
  default => sub{ EzyApp::Test::UserAgent::Res->new() }
);

no Moose;
__PACKAGE__->meta->make_immutable;



package EzyApp::Test::UserAgent;
use Moose;

has tx => (
  is => 'ro', isa => 'Maybe[Object]',
  default => sub{ EzyApp::Test::UserAgent::TX->new(res => shift->res) },
);

has res => (
  is => 'ro', isa => 'Maybe[Object]',
  default => sub{ EzyApp::Test::UserAgent::Res->new },
);

sub get{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($url) = @_;
  my $json = $self->tx->res->json;
  $json->{_req} = { url => $url, method => 'GET' }
    if $json && ref $json eq 'HASH' && exists $json->{_req};
  if ($callback){
    $callback->($self, $self->tx);
  } else {
    return $self->tx;
  }
}

sub post{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($url, $payload) = @_;
  my $json = $self->tx->res->json;
  $json->{_req} = { url => $url, method => 'POST' }
    if $json && ref $json eq 'HASH' && exists $json->{_req};
  if ($callback){
    $callback->($self, $self->tx);
  } else {
    return $self->tx;
  }
}


no Moose;
__PACKAGE__->meta->make_immutable;
