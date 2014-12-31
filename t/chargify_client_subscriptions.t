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

$client->user_agent->res->json([{ subscription => {}}]);

my $data = $client->list();
my ($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json', 'request url';
is $payload, undef, 'no payload';

$data = $client->list({ page => 2, per_page => 10 });
($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json', 'request url';
is_deeply $payload, { form => { page => 2, per_page => 10 }}, 'payload';

$client->list(sub{
  my ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json', 'request url';
  is $payload, undef, 'no payload';
});

$client->user_agent->res->json([]);

$data = $client->list();

($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json', 'request url';
is $payload, undef, 'no payload';

$client->list(sub{
  my ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json', 'request url';
  is $payload, undef, 'no payload';
});

$client->user_agent->res->json(undef);

$data = $client->list();

($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json', 'request url';
is $payload, undef, 'no payload';

$client->list(sub{
  my ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions.json', 'request url';
  is $payload, undef, 'no payload';
});

# single subscription

$client->user_agent->res->json({ subscription => {}});

$data = $client->single('bogus_id');
($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id.json', 'request url';
is $payload, undef, 'no payload';

$client->single('bogus_id', sub{
  ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id.json', 'request url';
  is $payload, undef, 'no payload';
});

$client->user_agent->res->json(undef);

$data = $client->single('bogus_id');
($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id.json', 'request url';
is $payload, undef, 'no payload';

$client->single('bogus_id', sub{
  ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id.json', 'request url';
  is $payload, undef, 'no payload';
});

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

$client->user_agent->res->json([{ component => { component_id => 1 }}]);

$data = $client->components('bogus_id');
is_deeply $data, [{ id => 1 }], 'response data';
($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id/components.json', 'request url';
is $payload, undef, 'no payload';


$client->user_agent->res->json([{ component => { component_id => 1 }}]);

$client->components('bogus_id', sub{
  my ($err, $data) = @_;
  is_deeply $data, [{ id => 1 }], 'response data';
  ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id/components.json', 'request url';
  is $payload, undef, 'no payload';
});


for my $json ([], undef){
  $client->user_agent->res->json($json);

  $data = $client->components('bogus_id');
  is $data, undef, 'response data';
  ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id/components.json', 'request url';
  is $payload, undef, 'no payload';

  $client->components('bogus_id', sub{
    my ($err, $data) = @_;
    is $data, undef, 'response data';
    ($method, $url, $payload) = @{$client->last_request};
    is $method, 'get', 'request method';
    is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/bogus_id/components.json', 'request url';
    is $payload, undef, 'no payload';
  });
}



$client->user_agent->res->json([{ event => { id => 987654321 }}]);

$data = $client->events(987654321);
is_deeply $data, [{ id => 987654321 }], 'response data';
($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/987654321/events.json', 'request url';
is_deeply $payload, {'form' => undef }, 'no payload';
# warn Dumper($payload);

$client->events(987654321, sub{
  my ($err, $data) = @_;
  is_deeply $data, [{ id => 987654321 }], 'response data';
  ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/987654321/events.json', 'request url';
  is_deeply $payload, {'form' => undef }, 'no payload';
});

$client->user_agent->res->json(undef);

$data = $client->events(987654321);
is $data, undef, 'response data';
($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/987654321/events.json', 'request url';
is_deeply $payload, {'form' => undef }, 'no payload';
# warn Dumper($payload);

$client->events(987654321, sub{
  my ($err, $data) = @_;
  is $data, undef, 'response data';
  ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/subscriptions/987654321/events.json', 'request url';
  is_deeply $payload, {'form' => undef }, 'no payload';
});

# print Data::Dumper->Dumper($events);

sub client{
  EzyApp::Chargify::Client::Subscriptions->new(
    api_key => 'bogus-api-key',
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => 0,
    user_agent => EzyApp::Test::UserAgent->new
  );
}

done_testing();
