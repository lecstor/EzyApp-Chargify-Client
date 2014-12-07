package EzyApp::Chargify::Client::Subscriptions;
use Moose;

with
  'EzyApp::Chargify::Role::Client',
  'EzyApp::Chargify::Role::ClientBasicAuth';

=item

  $subscriptions->fetch($page, $per_page);

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

sub fetch{
  my ($self, $page, $per_page) = @_;

  my $url = $self->fetch_url($page, $per_page);

  my $res;
  foreach my $try (1..3){
    $res = $self->try_fetch($url, $try);
    last if $res;
    $self->debug($res);
    if ($try < 3){
      $self->debug("Subscriptions Fetch: sleep for 30 then try again..");
      sleep(30);
    } else {
      $self->debug("Subscriptions Fetch: monumental fail!\n");
    }
  }

  $self->response($res);

  return $res->json();
}

=item fetch_url

  URL: https://<subdomain>.chargify.com/subscriptions.<format>
  Method: GET
  Optional Parameters:
  page: an integer value which specifies which page of results to fetch, starting at 1. Fetching successively higher page numbers will return additional results, until there are no more results to return (in which case an empty result set will be returned). Defaults to 1.
  per_page: how many records to fetch in each request, defaults to 20. The maximum allowed is 200 – any per_page value over 200 will be changed to 200.

=cut

sub fetch_url{
  my ($self, $page, $per_page) = @_;
  $page ||= 1;
  $per_page ||= 200;
  my $url = $self->base_url;
  $url .= sprintf '/subscriptions.json?page=%s&per_page=%s', $page, $per_page;
  $self->debug("Subscriptions fetch url: $url");
  return $url;
}

sub try_fetch{
  my ($self, $url) = @_;
  my $res = $self->user_agent->get($url)->res;
  $self->debug("Subscriptions Fetch Message: ".$res->message."\n");
  return $res if lc($res->message) eq 'ok';
  return;
}


no Moose;
__PACKAGE__->meta->make_immutable;

