package EzyApp::Chargify::Client::Statements;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';


=item get_by_id

return a document by id

    $id = $store->get_by_id($id);

=cut

sub get_by_id{
    my ($self, $id) = @_;
    my $url = $self->base_url;
    $url .= sprintf '/statements/%s.json', $id;
    my $res = $self->user_agent->get($url)->res;
    return $res if lc($res->message) eq 'ok';
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

