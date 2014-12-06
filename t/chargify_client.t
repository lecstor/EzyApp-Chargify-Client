use Mojo::Base -strict;

# test basic api functionality

use Test::More;

use_ok 'EzyApp::Chargify::Client';

my $client = EzyApp::Chargify::Client->new(
  config => {
    api_key => 'abc123',
    api_host => 'subdomain.example.com',
    site_id => 'sd',
    ua_inactivity_timeout => 120,
    debug_on => 1,
  }
);

ok $client, 'new api';

foreach my $model (qw!components events products statements subscriptions transactions!){
  is $client->$model->base_url, 'https://abc123:x@subdomain.example.com', $model.' base_url ok';
}


done_testing();
