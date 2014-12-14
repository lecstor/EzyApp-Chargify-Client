use Mojo::Base -strict;

# test basic api functionality

use Test::More;
use Data::Dumper;

use_ok 'EzyApp::Chargify::Client';

my $client = EzyApp::Chargify::Client->new(
  config => {
    api_key => 'bogus-api-key',
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => 1,
  }
);

ok $client, 'new api';

foreach my $model (qw!components events products statements subscriptions transactions!){
  is $client->$model->base_url, "https://bogus-api-key:x\@ezyapp.chargify.com", $model.' base_url ok';
}

# print Data::Dumper->Dumper($events);

done_testing();
