package EzyApp::Chargify::Client::Components;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';


sub fetch{
    my ($self, $product_family_id) = @_;

    my $url = $self->_fetch_url($product_family_id);
    my $res = $self->user_agent->get($url)->res;
    $self->debug("Components Fetch Message: ".$res->message."\n");

    $self->response($res);

    return $res->json();
}

sub _fetch_url{
    my ($self, $product_family_id) = @_;
    my $url = $self->base_url;
    $url .= sprintf '/product_families/%s/components.json', $product_family_id;
    $self->debug("chargify components fetch url: $url");
    return $url;
}


no Moose;
__PACKAGE__->meta->make_immutable;


__END__

[
    {
        "component": {
            "id": 33702,
            "name": "Annual Extra Devices",
            "pricing_scheme": "per_unit",
            "unit_name": "extra device",
            "unit_price": "60.0",
            "product_family_id": 352718,
            "price_per_unit_in_cents": null,
            "kind": "quantity_based_component",
            "archived": false,
            "taxable": true,
            "description": "Increases to device limits allocated to users.",
            "prices": [
                {
                    "starting_quantity": 1,
                    "ending_quantity": null,
                    "unit_price": "60.0"
                }
            ]
        }
    },
    {
        "component": {
            "id": 26885,
            "name": "Annual User Seats",
            "pricing_scheme": "tiered",
            "unit_name": "annual seat",
            "unit_price": null,
            "product_family_id": 352718,
            "price_per_unit_in_cents": null,
            "kind": "quantity_based_component",
            "archived": false,
            "taxable": false,
            "description": "",
            "prices": [
                {
                    "starting_quantity": 1,
                    "ending_quantity": 500,
                    "unit_price": "60.0"
                },
                {
                    "starting_quantity": 501,
                    "ending_quantity": 1000,
                    "unit_price": "0.0"
                }
            ]
        }
    },
    {
        "component": {
            "id": 33701,
            "name": "Extra Devices",
            "pricing_scheme": "per_unit",
            "unit_name": "extra device",
            "unit_price": "5.0",
            "product_family_id": 352718,
            "price_per_unit_in_cents": null,
            "kind": "quantity_based_component",
            "archived": false,
            "taxable": true,
            "description": "Increases to device limits allocated to users.",
            "prices": [
                {
                    "starting_quantity": 1,
                    "ending_quantity": null,
                    "unit_price": "5.0"
                }
            ]
        }
    },
    {
        "component": {
            "id": 24993,
            "name": "User Seats",
            "pricing_scheme": "tiered",
            "unit_name": "user",
            "unit_price": null,
            "product_family_id": 352718,
            "price_per_unit_in_cents": null,
            "kind": "quantity_based_component",
            "archived": false,
            "taxable": true,
            "description": "Testing use only",
            "prices": [
                {
                    "starting_quantity": 1,
                    "ending_quantity": 500,
                    "unit_price": "5.0"
                },
                {
                    "starting_quantity": 501,
                    "ending_quantity": 1000,
                    "unit_price": "0.0"
                }
            ]
        }
    }
]
