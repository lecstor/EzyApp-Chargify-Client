package EzyApp::Chargify::Client::Events;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';

=item list

  $events = $client->list();

  $events = $client->list({
    page => 1,
    per_page => 30,
    direction => 'desc'
    since_id => 54321,
    max_id => 65432,
  });

  $client->list(
    {
      page => 1,
      per_page => 30,
      direction => 'desc'
      since_id => 54321,
      max_id => 65432,
    },
    sub{ my ($err, data) = @_; }
  );

=cut

sub list{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($options) = @_;
  my $url = $self->base_url. sprintf '/events.json';

  if ($callback){
    return $self->_request('get', $url, { form => $options }, sub{
      my ($err, $list) = @_;
      $callback->($err, ($list && @$list) ? [map{ $_->{event} } @$list] : undef);
    });
  } else {
    my $list = $self->_request('get', $url, { form => $options });
    return unless $list && @$list;
    return [map{ $_->{event} } @$list];
  }

}

no Moose;
__PACKAGE__->meta->make_immutable;

