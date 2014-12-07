use Mojo::Base -strict;

# test basic api functionality

use Test::More;
use Data::Dumper;

use_ok 'EzyApp::Chargify::Client';

my $client = EzyApp::Chargify::Client->new(
  config => {
    api_key => 'c1fCSCQhCheAz986QC',
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => 1,
  }
);

ok $client, 'new api';

foreach my $model (qw!components events products statements subscriptions transactions!){
  is $client->$model->base_url, 'https://c1fCSCQhCheAz986QC:x@ezyapp.chargify.com', $model.' base_url ok';
}

my $subs_client = $client->subscriptions;
my $subs = $subs_client->fetch();
ok @$subs >= 2, '>= 2 subs found';
ok $subs->[0]->{subscription}, 'item has subscription property';

my $events_client = $client->events;
my $events = $events_client->fetch;

ok @$events >= 1, '>= 1 events found';
ok $events->[0]->{event}, 'item has event property';


print Data::Dumper->Dumper($events);

done_testing();
