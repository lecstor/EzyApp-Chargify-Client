package EzyApp::Chargify::Client::Subscriptions;
use Moose;

with
  'EzyApp::Chargify::Role::Client',
  'EzyApp::Chargify::Role::ClientBasicAuth';

=header SYNOPSIS

  $subs = EzyApp::Chargify::Client::Subscriptions->new(
    api_key => 'abc123',
    api_host => 'subdomain.example.com',
    ua_inactivity_timeout => 120,
    debug_on => 1,
  );

  $subscriptions->list($page, $per_page);

  Returns the json response body

  [
    {
      "subscription": {
        "id": 5788298,
        "state": "trialing",
        "balance_in_cents": 0,
        "total_revenue_in_cents": 0,
        "product_price_in_cents": 500,
        "product_version_number": 1,
        "current_period_ends_at": "2014-07-30T15:04:17+10:00",
        "next_assessment_at": "2014-07-30T15:04:17+10:00",
        "trial_started_at": "2014-06-30T15:04:17+10:00",
        "trial_ended_at": "2014-07-30T15:04:17+10:00",
        "activated_at": null,
        "expires_at": null,
        "created_at": "2014-06-30T15:04:17+10:00",
        "updated_at": "2014-06-30T15:04:22+10:00",
        "cancellation_message": null,
        "cancel_at_end_of_period": false,
        "canceled_at": null,
        "current_period_started_at": "2014-06-30T15:04:17+10:00",
        "previous_state": "trialing",
        "signup_payment_id": 12345678,
        "signup_revenue": "0.00",
        "delayed_cancel_at": null,
        "coupon_code": null,
        "payment_collection_method": "automatic",
        "customer": {
          "first_name": "John",
          "last_name": "Smith",
          "email": "john@ezyapp.com"
          "organization": null,
          "reference": "john-ezyapp-com",
          "id": 5670424,
          "created_at": "2014-06-30T15:04:17+10:00",
          "updated_at": "2014-06-30T15:04:17+10:00",
          "address": null,
          "address_2": null,
          "city": null,
          "state": null,
          "zip": null,
          "country": "AU",
          "phone": null,
          "verified": false,
          "portal_customer_created_at": null,
          "portal_invite_last_sent_at": null,
          "portal_invite_last_accepted_at": null
        },
        "product": {
          "id": 3325005,
          "name": "Product One",
          "handle": "product-one",
          "description": "",
          "accounting_code": "",
          "price_in_cents": 5000,
          "interval": 1,
          "interval_unit": "month",
          "initial_charge_in_cents": 0,
          "expiration_interval": null,
          "expiration_interval_unit": "never",
          "trial_price_in_cents": 0,
          "trial_interval": 30,
          "trial_interval_unit": "day",
          "return_url": "",
          "return_params": "",
          "request_credit_card": true,
          "require_credit_card": false,
          "created_at": "2013-07-31T16:29:43+10:00",
          "updated_at": "2014-05-26T09:20:23+10:00",
          "archived_at": null,
          "update_return_url": "",
          "product_family": {
            "id": 352809,
            "name": "EzyApp Plans",
            "handle": "ezyapp-plans",
            "accounting_code": null,
            "description": ""
          },
          "taxable": true
        },
        "credit_card": null,
        "payment_type": null
      }
    },
  ]

=cut

=item single

  $subscriptions->single($id, sub{
    my ($err, $data) = @_;
    if ($err){
      if ($err->{code}){
        warn "$err->{code} response: $err->{message}";
      } else {
        warn "Connection error: $err->{message}";
      }
    } else {
      warn Dumper $data;
    }
  })

  my $data;
  try{ $data = $subscriptions->single($id) }
  catch { die $_ };

=cut

sub single{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($id) = @_;
  my $url = $self->base_url. sprintf "/subscriptions/$id.json";

  return $self->_request('get', $url)->{subscription} unless $callback;

  return $self->_request('get', $url, sub{
    my ($err, $sub) = @_;
    $callback->($err, $sub ? $sub->{subscription} : undef);
  });
}

=item list

  page: an integer value which specifies which page of results to fetch, starting at 1. Fetching successively higher page numbers will return additional results, until there are no more results to return (in which case an empty result set will be returned). Defaults to 1.
  per_page: how many records to fetch in each request, defaults to 20. The maximum allowed is 200 – any per_page value over 200 will be changed to 200.

=cut

sub list{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($page, $per_page) = @_;
  $page ||= 1;
  $per_page ||= 200;
  my $url = $self->base_url. sprintf '/subscriptions.json?page=%s&per_page=%s', $page, $per_page;

  return [map{ $_->{subscription} } @{$self->_request('get', $url)}] unless $callback;

  return $self->_request('get', $url, sub{
    my ($err, $list) = @_;
    $callback->($err, $list ? [map{ $_->{subscription} } @$list] : undef);
  });
}

=item components

=cut

sub components{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($id) = @_;
  my $url = $self->base_url. sprintf "/subscriptions/$id/components.json";

  if ($callback){
    return $self->_request('get', $url, sub{
      my ($err, $list) = @_;
      my $components = [map{ $_->{component} } @$list];
      $_->{id} = delete($_->{component_id}) foreach @$components;
      $callback->($err, $list ? $components : undef);
    });

  } else {
    my $components = [map{ $_->{component} } @{$self->_request('get', $url)}];
    $_->{id} = delete($_->{component_id}) foreach @$components;
    return $components;

  }

}

=item allocations

  $allocs = $subs->allocations($sub_id, $component_id);

  $allocs = $subs->allocations($sub_id, $component_id, $page);

  $subs->allocations($sub_id, $component_id, $page, $callback);

  $subs->allocations($sub_id, $component_id, $callback);

=cut

sub allocations{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($id, $comp_id, $page) = @_;
  my $url = $self->base_url. sprintf "/subscriptions/$id/components/$comp_id/allocations";

  return [
    map{ $_->{allocation} } @{$self->_request('get', $url, {form => {page => $page}}) }
  ] unless $callback;

  return $self->_request('get', $url, {form => {page => $page}}, sub{
    my ($err, $list) = @_;
    $callback->($err, $list ? [map{ $_->{allocation} } @$list] : undef);
  });
}

=item events

curl -G -u zTNKtWlZYgNkoMXKuq8:x -H Accept:application/json -H Content-Type:application/json \
-d page=1 https://ezyapp.chargify.com/subscriptions//events.json

=cut

sub events{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($id, $options) = @_;
  my $url = $self->base_url. sprintf '/subscriptions/%s/events.json', $id;

  return [map{ $_->{event} } @{$self->_request('get', $url, { form => $options })}] unless $callback;

  return $self->_request('get', $url, { form => $options }, sub{
    my ($err, $list) = @_;
    $callback->($err, $list ? [map{ $_->{event} } @$list] : undef);
  });
}


no Moose;
__PACKAGE__->meta->make_immutable;

