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

my $data = $client->list({ min_id => 54321, max_id => 12345, direction => 'asc', limit => 30, page => 3 });
is $data->{_req}{method}, 'GET', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com/events.json?page=3&per_page=30&since_id=54321&max_id=12345&direction=asc', 'request url';


$client->list(sub{
  my ($err, $data) = @_;
  ok !$err, 'list no error';
  ok $data, 'list data';
  is $data->{_req}{method}, 'GET', 'request method';
  is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com/events.json?page=&per_page=&since_id=&max_id=&direction=', 'request url';
  Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;


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
