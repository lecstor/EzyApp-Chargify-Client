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
  my ($self, $callback) = @_;
  my $url = $self->base_url;
  return $self->_request('post', $url, { payload_key => 'value' }, $callback);
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

my $api_key = 'bogus-api-key';

# GET

my $client = client(
  EzyApp::Test::UserAgent->new(
    res => EzyApp::Test::UserAgent::Res->new(
      json => { key => 'value' }
    )
  ),
);
ok $client, 'new client';

# test coverage for debug
$client->debug_on(1);
$client->debug({ debug => 'ref' });
$client->debug('debug string');
$client->debug_on(0);


my $data = $client->get();
ok $data, 'got data';
is $data->{key}, 'value', 'data format';
is $data->{_req}{method}, 'GET', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com', 'request url';

$client->get(sub{
  my ($err, $data) = @_;
  ok !$err, 'get no error';
  ok $data, 'get data';
  is $data->{key}, 'value', 'data format';
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

$client = client(
  EzyApp::Test::UserAgent->new(
    res => EzyApp::Test::UserAgent::Res->new(
      json => { key => 'value' }
    )
  )
);

$data = $client->post({ key => 'value' });
ok $data, 'got data';
is $data->{key}, 'value', 'data format';
is $data->{_req}{method}, 'POST', 'request method';
is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com', 'request url';

$client->post(sub{
  my ($err, $data) = @_;
  ok !$err, 'get no error';
  ok $data, 'get data';
  is $data->{key}, 'value', 'data format';
  is $data->{_req}{method}, 'POST', 'request method';
  is $data->{_req}{url}, 'https://bogus-api-key:x@ezyapp.chargify.com', 'request url';
  Mojo::IOLoop->stop;
});
Mojo::IOLoop->start;




done_testing();

sub client{
  my ($useragent, $debug) = @_;
  Test::Client->new(
    api_key => $api_key,
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => $debug || 0,
    user_agent => $useragent
  );
}
