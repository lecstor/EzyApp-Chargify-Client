package EzyApp::Chargify::Client;
use Moose;

use EzyApp::Chargify::Client::Components;
use EzyApp::Chargify::Client::Events;
use EzyApp::Chargify::Client::Products;
use EzyApp::Chargify::Client::Statements;
use EzyApp::Chargify::Client::Subscriptions;
use EzyApp::Chargify::Client::Transactions;

=item new

    my $api = EzyApp::Chargify::Client->new(
        config => {
            api_key => 'abc123',
            api_host => 'subdomain.example.com',
            site_id => 'sd',
            ua_inactivity_timeout => 120,
            debug_on => 1,
        }
    );

=cut

has config => (
    is => 'ro',
);

has components => (
    is => 'ro',
    lazy => 1,
    default => sub{
        EzyApp::Chargify::Client::Components->new(shift->config);
    }
);

has events => (
    is => 'ro',
    lazy => 1,
    default => sub{
        EzyApp::Chargify::Client::Events->new(shift->config);
    }
);

has products => (
    is => 'ro',
    lazy => 1,
    default => sub{
        EzyApp::Chargify::Client::Products->new(shift->config);
    }
);

has statements => (
    is => 'ro',
    lazy => 1,
    default => sub{
        EzyApp::Chargify::Client::Statements->new(shift->config);
    }
);

has subscriptions => (
    is => 'ro',
    lazy => 1,
    default => sub{
        EzyApp::Chargify::Client::Subscriptions->new(shift->config);
    }
);

has transactions => (
    is => 'ro',
    lazy => 1,
    default => sub{
        EzyApp::Chargify::Client::Transactions->new(shift->config);
    }
);




no Moose;
__PACKAGE__->meta->make_immutable;

__END__

Products

    get products
    GET /products.json

    get a product
    GET /products/{product_id}.json
    GET /products/handle/{product_handle}.json

    get products for a product family
    GET /product_families/{product_family_id}/products.json

Components

    get components for a product family
    GET /product_families/{product_family_id}/components.json

Statements

    get statement ids
    GET /statements/ids.json

    get a statement
    GET /statements/{statement_id}.json

Subscriptions

    get subscriptions
    GET /subscriptions.json

    get a subscription
    GET /subscriptions/{subscription_id}.json

    get components for a subscription
    GET /subscriptions/{subscription_id}/components

    get a component for a subscription
    GET /subscriptions/{subscription_id}/components/:component_id

    get events for a subscription
    GET /subscriptions/{subscription_id}/events.json

    get statements for a subscription
    GET /subscriptions/{subscription_id}/statements.json

    get transactions for a subscription
    GET /subscriptions/{subscription_id}/transactions.json


Customers

    get customers
    GET /customers.json

    get a customer
    GET /customers/{customer_id}.json
    GET /customers/lookup.json?reference={reference}

    get subscriptions
    GET /customers/{customer_id}/subscriptions.json

Events

    get events
    GET /events.json

Invoices

    get invoices
    GET /invoices.json

    get an invoice
    GET /invoices/{invoice_id}.json

Transactions

    get transactions
    GET /transactions.json

    get a transaction
    GET /transactions/{transaction_id}.json

