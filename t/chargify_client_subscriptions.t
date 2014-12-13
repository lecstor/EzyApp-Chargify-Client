use Mojo::Base -strict;

# test basic api functionality

use Test::More;
use Data::Dumper 'Dumper';
use Try;

use EzyApp::Test::UserAgent;

use_ok 'EzyApp::Chargify::Client::Subscriptions';

my $client = client();

ok $client, 'new api';

# list subscriptions

my $data = $client->list();
is $data->{_req}{method}, 'GET', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json?page=1&per_page=200', 'request url';

$data = $client->list(2, 10);
is $data->{_req}{method}, 'GET', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json?page=2&per_page=10', 'request url';


# single subscription

$data = $client->single('bogus_id');
is $data->{_req}{method}, 'GET', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id.json', 'request url';

# components

# curl -u <api_key>:x -H Accept:application/json -H Content-Type:application/json https://ezyapp.chargify.com/subscriptions//components.json
# [
#   {
#     "component" => {
#       "component_id" => 71190,
#       "subscription_id" => 7174862,
#       "allocated_quantity" => 2,
#       "pricing_scheme" => "per_unit",
#       "name" => "Quantity Unit Component",
#       "kind" => "quantity_based_component",
#       "unit_name" => "quantity-unit"
#     }
#   }
# ]

$data = $client->components('bogus_id');
is $data->{_req}{method}, 'GET', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id/components.json', 'request url';

# print Data::Dumper->Dumper($events);

sub client{
  my ($useragent, $api_key, $debug) = @_;
  EzyApp::Chargify::Client::Subscriptions->new(
    api_key => $api_key || 'bogus-api-key',
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => $debug || 0,
    user_agent => $useragent || EzyApp::Test::UserAgent->new
  );
}

done_testing();
