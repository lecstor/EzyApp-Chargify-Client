package EzyApp::Chargify::Client::Events;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';

=item

    $events->fetch(
        direction => 'asc',
        limit => 50,
        since_event => 54321,
        until_event => 654321,
    );

    Returns the json response body

=cut

sub fetch{
    my ($self, %args) = @_;

    my $direction = $args{direction} || 'asc';
    my $limit = $args{limit} || 50;

    my $url = $self->_fetch_url($direction, $limit, $args{since_event}, $args{until_event});

    my $res;
    foreach my $try (1..3){
        $res = $self->_try_fetch($url, $try);
        last if $res;
        $self->debug($res);
        if ($try < 3){
            $self->debug("Events Fetch: sleep for 30 then try again..");
            sleep(30);
        } else {
            $self->debug("Events Fetch: monumental fail!\n");
        }
    }

    $self->response($res);

    return $res->json();
}

sub _fetch_url{
    my ($self, $direction, $limit, $since_event, $until_event) = @_;
    my $url = $self->base_url;
    $url .= sprintf '/events.json?direction=%s&per_page=%s', $direction, $limit;
    $url .= '&since_id='.$since_event if $since_event;
    $url .= '&max_id='.$until_event if $until_event;
    $self->debug("chargify events fetch url: $url");
    return $url;
}

sub _try_fetch{
    my ($self, $url) = @_;
    my $res = $self->user_agent->get($url)->res;
    $self->debug("Events Fetch Message: ".$res->message."\n");
    return $res if lc($res->message) eq 'ok';
    return;
}


no Moose;
__PACKAGE__->meta->make_immutable;

