package EzyApp::Chargify::Client::Products;
use Moose;

with
  'EzyApp::Chargify::Role::Client',
  'EzyApp::Chargify::Role::ClientBasicAuth';

=item list

We cannot get product version via this API.

Better to collect products from subscriptions so we can get different versions.

Subscriptions have:

  {
    "product_version_number": 1,
    "product":{
      "id":`auto generated`,
      "name":`your value`,
      "handle":`your value`,
      "description":`your value`,
      "price_in_cents":`your value`,
      "accounting_code":`your value`,
      "interval":`your value`,
      "interval_unit":`your value`,
      "initial_charge_in_cents":null,
      "trial_price_in_cents":null,
      "trial_interval":null,
      "trial_interval_unit":null,
      "expiration_interval_unit":null,
      "expiration_interval":null,
      "return_url":null,
      "update_return_url":null,
      "return_params":null,
      "require_credit_card":true,
      "request_credit_card":true,
      "created_at":`auto generated`,
      "updated_at":`auto generated`,
      "archived_at":null,
      "product_family":{
        "id":`auto generated`,
        "name":`your value`,
        "handle":`your value`,
        "accounting_code":`your value`,
        "description":`your value`
      }
    },
  }

=cut

sub list{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';

  my $url = $self->base_url. '/products.json';

  if ($callback){
    return $self->_request('get', $url, sub{
      my ($err, $list) = @_;
      $callback->($err, $list ? [map{ $_->{product} } @$list] : undef);
    });
  } else {
    my $resp = $self->_request('get', $url);
    return unless $resp;
    return [map{ $_->{product} } @$resp];
  }
}

no Moose;
__PACKAGE__->meta->make_immutable;


