use Mojo::Base -strict;

# test basic api functionality

use Test::More;
use Mojo::IOLoop;
use Data::Dumper 'Dumper';
use Try;

use EzyApp::Test::UserAgent;

use_ok 'EzyApp::Chargify::Client::Products';

my $client = client();

ok $client, 'new api';

# list components

$client->user_agent->res->json([{ product => {}}]);

my $data = $client->list;

my ($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/products.json', 'request url';
is $payload, undef, 'no payload';


$client->list(sub{
  my ($err, $data) = @_;
  my ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/products.json', 'request url';
  is $payload, undef, 'no payload';
  Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;



$client->user_agent->res->json(undef);

$data = $client->list;
is $data, undef, 'no data';
($method, $url, $payload) = @{$client->last_request};
is $method, 'get', 'request method';
is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/products.json', 'request url';
is $payload, undef, 'no payload';


$client->list(sub{
  my ($err, $data) = @_;
  is $data, undef, 'no data';
  my ($method, $url, $payload) = @{$client->last_request};
  is $method, 'get', 'request method';
  is $url, 'https://bogus-api-key:x@ezyapp.chargify.com/products.json', 'request url';
  is $payload, undef, 'no payload';
  Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;



# warn Dumper($payload);


sub client{
  EzyApp::Chargify::Client::Products->new(
    api_key => 'bogus-api-key',
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => 0,
    user_agent => EzyApp::Test::UserAgent->new
  );
}

done_testing();
