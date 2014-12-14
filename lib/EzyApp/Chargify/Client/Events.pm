package EzyApp::Chargify::Client::Events;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';

=item list

  $events = $client->list();

  $events = $client->list({
    min_id => 54321, direction => 'asc',
    limit => 30, page => 3
  });

  $client->list(
    {
      min_id => 54321, direction => 'asc',
      limit => 30, page => 3
    },
    sub{ my ($err, data) = @_; }
  );

=cut

sub list{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($options) = @_;
  $options ||= {};
  foreach (qw!page limit min_id max_id direction!){ $options->{$_} ||= '' };
  my $url = $self->base_url. sprintf '/events.json?page=%s&per_page=%s&since_id=%s&max_id=%s&direction=%s',
    $options->{page}, $options->{limit}, $options->{min_id}, $options->{max_id}, $options->{direction};
  return $self->_request('get', $url, $callback);
}

no Moose;
__PACKAGE__->meta->make_immutable;

