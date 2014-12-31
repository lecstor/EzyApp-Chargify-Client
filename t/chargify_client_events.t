use Mojo::Base -strict;

# test chargify events client

use Test::More;
use Data::Dumper 'Dumper';
use Try;

use EzyApp::Test::UserAgent;

use_ok 'EzyApp::Chargify::Client::Events';

# curl -G -u zTNKtWlZYgNkoMXKuq8:x -H Accept:application/json -H Content-Type:application/json -d page=2 -d per_page=3 -d direction= https://ezyapp.chargify.com/events.json

my $client = client();

ok $client, 'new client';

$client->user_agent->res->json([{ event => {}}]);

my $data = $client->list({ min_id => 54321, max_id => 12345, direction => 'asc', per_page => 30, page => 3 });

my ($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/events.json', 'request url';

# warn Dumper($payload);
is_deeply $payload, { form => {
  page => 3, per_page => 30, min_id => 54321, max_id => 12345, direction => 'asc'
}}, 'payload';


$client->list({ min_id => 54321, max_id => 12345, direction => 'asc', per_page => 30, page => 3 }, sub{
  my ($err, $data) = @_;
  ok !$err, 'list no error';
  ok $data, 'list data';

  my ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/events.json', 'request url';

  is_deeply $payload, { form => {
    page => 3, per_page => 30, min_id => 54321, max_id => 12345, direction => 'asc'
  }}, 'payload';

  Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;

$client->user_agent->res->json(undef);

$data = $client->list(
  { min_id => 54321, max_id => 12345, direction => 'asc', per_page => 30, page => 3 },
  sub{
    my ($err, $data) = @_;
    ok !$err, 'list no error';
    is_deeply $data, undef, 'empty response';
    Mojo::IOLoop->stop;
  }
);
Mojo::IOLoop->start;


# my ($method, $url, $payload) = @{$client->last_request};
# is $method, 'get', 'request method';
# is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/events.json', 'request url';

# # warn Dumper($payload);
# is_deeply $payload, { form => {
#   page => 3, per_page => 30, min_id => 54321, max_id => 12345, direction => 'asc'
# }}, 'payload';

# print Data::Dumper->Dumper($events);

sub client{
  EzyApp::Chargify::Client::Events->new(
    api_key => 'bogus-api-key',
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => 0,
    user_agent => EzyApp::Test::UserAgent->new
  );
}

done_testing();
