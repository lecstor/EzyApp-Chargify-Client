package EzyApp::Chargify::Client::Products;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';


sub fetch{
    my ($self) = @_;

    my $url = $self->_fetch_url();
    my $res = $self->user_agent->get($url)->res;
    $self->debug("Products Fetch Message: ".$res->message."\n");

    $self->response($res);

    return $res->json();
}

sub _fetch_url{
    my ($self) = @_;
    my $url = $self->base_url;
    $url .= sprintf '/products.json';
    $self->debug("chargify products fetch url: $url");
    return $url;
}


# https://<subdomain>.chargify.com/products/<id>.<format>

no Moose;
__PACKAGE__->meta->make_immutable;


