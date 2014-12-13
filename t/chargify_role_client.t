package Test::Client;
use Moose;

with
  'EzyApp::Chargify::Role::Client',
  'EzyApp::Chargify::Role::ClientBasicAuth';

sub get{
  my ($self, $callback) = @_;
  my $url = $self->base_url;
  return $self->_request('get', $url, $callback);
}

sub post{
  my ($self, $payload, $callback) = @_;
  my $url = $self->base_url;
  return $self->_request('post', $url, $payload, $callback);
}

no Moose;
__PACKAGE__->meta->make_immutable;



package main;

use Mojo::Base -strict;

# test basic api functionality

use Test::More;
use Data::Dumper 'Dumper';
use Try;

use EzyApp::Test::UserAgent;


# GET

my $client = client();
ok $client, 'new client';

# test coverage for debug
$client->debug_on(1);
$client->debug({ debug => 'ref' });
$client->debug('debug string');
$client->debug_on(0);


my $data = $client->get();
ok $data, 'got data';
is $data->{_req}{method}, 'GET', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com', 'request url';

$client->get(sub{
  my ($err, $data) = @_;
  ok !$err, 'get no error';
  ok $data, 'get data';
  is $data->{_req}{method}, 'GET', 'request method';
  is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com', 'request url';
  Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;


$client = client(
  EzyApp::Test::UserAgent->new(
    tx => EzyApp::Test::UserAgent::TX->new(
      error => { code => '404', message => 'Test Not Found' }
    )
  ),
);

try{
  $client->get();
  ok 0, 'did not die';
} catch {
  is $_, "404 Test Not Found\n", 'subscription not found'
}


$client = client(
  EzyApp::Test::UserAgent->new(
    tx => EzyApp::Test::UserAgent::TX->new(
      error => { message => 'Test Connect Fail' }
    )
  ),
);

try{
  $client->get();
  ok 0, 'did not die';
} catch {
  is $_, "Connection error: Test Connect Fail\n", 'connection failure'
}


# POST

$client = client();

my $payload = { key => 'value' };

$data = $client->post($payload);
ok $data, 'got data';
is_deeply $data->{_req}{payload}{json}, $payload, 'request json payload';
is $data->{_req}{method}, 'POST', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com', 'request url';

$client->post($payload, sub{
  my ($err, $data) = @_;
  ok !$err, 'get no error';
  ok $data, 'get data';
  is_deeply $data->{_req}{payload}{json}, $payload, 'request json payload';
  is $data->{_req}{method}, 'POST', 'request method';
  is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com', 'request url';
  Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;




done_testing();

sub client{
  my ($useragent, $debug) = @_;
  Test::Client->new(
    api_key => 'bogus-api-key',
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => $debug || 0,
    user_agent => $useragent || EzyApp::Test::UserAgent->new
  );
}
