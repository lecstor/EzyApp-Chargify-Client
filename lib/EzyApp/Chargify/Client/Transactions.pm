package EzyApp::Chargify::Client::Transactions;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';

=header Transactions

 - can fetch by date range
 - can limit to charges
 - can ignore taxes
 - can break down by subscription & components
 - reliable for lifetime of client
 - minimal number of records

 - annual subscriptions not included monthly
 - cancellation only known by detecting missing transations
 - downgrade/upgrade only known by comparing to previous transactions

 Derived collection
 - signup date
 - transaction month
 - revenue
 - increase in revenue
 - decrease in revenue
 - status


MRR
- total: sum of all recurring revenue received in month (include portion of annual and others)
    - sum all transactions during the month
    - sum of prorata amounts of payments for periods > 1 month
- new: sum of all revenue from subscriptions created in the month
    - use signup date
- upgrade: sum of all revenue from existing subscriptions that increased since previous month

- downgrade: sum of all revenue from existing subscriptions that decreased since previous month



=cut

=item

    $transactions->fetch(
        direction => 'asc',
        limit => 50,
        since_id => 54321,
        until_id => 654321,
    );

    Returns the json response body
    [
        {
            "transaction": {
                "amount_in_cents": 0,
                "component_id": null,
                "created_at": "2013-11-01T15:05:27+11:00",
                "ending_balance_in_cents": 0,
                "gateway_used": null,
                "id": 42422199,
                "kind": "baseline",
                "memo": "Organisation (11/01/2013 - 12/01/2013)",
                "payment_id": 42422225,
                "product_id": 3346682,
                "starting_balance_in_cents": 0,
                "subscription_id": 4116103,
                "success": true,
                "tax_id": null,
                "type": "Charge",
                "transaction_type": "charge",
                "gateway_transaction_id": null,
                "gateway_order_id": null,
                "statement_id": 24891993,
                "customer_id": 3970814
            }
        },
        {
            "transaction": {
                "amount_in_cents": 1500,
                "component_id": null,
                "created_at": "2013-11-01T15:05:27+11:00",
                "ending_balance_in_cents": 1500,
                "gateway_used": null,
                "id": 42422200,
                "kind": "quantity_based_component",
                "memo": "User Seats: 3 users",
                "payment_id": 42422225,
                "product_id": 3346682,
                "starting_balance_in_cents": 0,
                "subscription_id": 4116103,
                "success": true,
                "tax_id": null,
                "type": "Charge",
                "transaction_type": "charge",
                "gateway_transaction_id": null,
                "gateway_order_id": null,
                "statement_id": 24891993,
                "customer_id": 3970814
            }
        },
        {
            "transaction": {
                "amount_in_cents": 150,
                "component_id": null,
                "created_at": "2013-11-01T15:05:27+11:00",
                "ending_balance_in_cents": 1650,
                "gateway_used": null,
                "id": 42422203,
                "kind": "tax",
                "memo": "Tax: GST",
                "payment_id": 42422225,
                "product_id": 3346682,
                "starting_balance_in_cents": 1500,
                "subscription_id": 4116103,
                "success": true,
                "tax_id": null,
                "type": "Charge",
                "transaction_type": "charge",
                "gateway_transaction_id": null,
                "gateway_order_id": null,
                "statement_id": 24891993,
                "customer_id": 3970814
            }
        },
    ]

=cut

sub fetch{
    my ($self, %args) = @_;

    my $direction = $args{direction} || 'asc';
    my $limit = $args{limit} || 200;

    my $url = $self->_fetch_url($direction, $limit, $args{since_id}, $args{until_id});

    my $res;
    foreach my $try (1..3){
        $res = $self->_try_fetch($url, $try);
        last if $res;
        $self->debug($res);
        if ($try < 3){
            $self->debug("Transactions Fetch: sleep for 30 then try again..");
            sleep(30);
        } else {
            $self->debug("Transactions Fetch: monumental fail!\n");
        }
    }

    $self->response($res);

    return $res->json();
}

sub _fetch_url{
    my ($self, $direction, $limit, $since_id, $until_id) = @_;
    my $url = $self->base_url;
    #$url .= sprintf '/transactions.json?direction=%s&per_page=%s&kinds[]=charge&kinds[]=payment', $direction, $limit;
    $url .= sprintf '/transactions.json?direction=%s&per_page=%s', $direction, $limit;
    $url .= '&since_id='.$since_id if $since_id;
    $url .= '&max_id='.$until_id if $until_id;
    $self->debug("chargify transactions fetch url: $url");
    return $url;
}

sub _try_fetch{
    my ($self, $url) = @_;
    my $res = $self->user_agent->get($url)->res;
    $self->debug("Transactions Fetch Message: ".$res->message."\n");
    return $res if lc($res->message) eq 'ok';
    return;
}


no Moose;
__PACKAGE__->meta->make_immutable;

