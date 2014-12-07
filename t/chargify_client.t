use Mojo::Base -strict;

# test basic api functionality

use Test::More;
use Data::Dumper;

use_ok 'EzyApp::Chargify::Client';

my $api_key = $ENV{CHARGIFY_API_KEY};

my $client = EzyApp::Chargify::Client->new(
  config => {
    api_key => $api_key,
    api_host => 'ezyapp.chargify.com',
    site_id => 'ea',
    ua_inactivity_timeout => 120,
    debug_on => 1,
  }
);

ok $client, 'new api';

foreach my $model (qw!components events products statements subscriptions transactions!){
  is $client->$model->base_url, "https://${api_key}:x\@ezyapp.chargify.com", $model.' base_url ok';
}

my $subs_client = $client->subscriptions;
my $subs = $subs_client->fetch();
ok @$subs >= 2, '>= 2 subs found';
ok $subs->[0]->{subscription}, 'item has subscription property';

my $events_client = $client->events;
my $events = $events_client->fetch;

ok @$events >= 1, '>= 1 events found';
ok $events->[0]->{event}, 'item has event property';

$events = $events_client->fetch( since_event => 120242965 );
is $events->[0]->{event}{id}, 120242965, 'events begin at specified id';

$events = $events_client->fetch( direction => 'desc', since_event => 120242965 );
is $events->[-1]->{event}{id}, 120242965, 'events desc to specified id';

$events = $events_client->fetch( direction => 'desc', until_event => 120242965 );
is $events->[0]->{event}{id}, 120242965, 'events desc from specified id';

# print Data::Dumper->Dumper($events);

done_testing();
