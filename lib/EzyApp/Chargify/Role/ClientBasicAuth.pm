package EzyApp::Chargify::Role::ClientBasicAuth;
use Moose::Role;


around '_builder_base_url' => sub{
    my $orig = shift;
    my $self = shift;
    my $url = $self->$orig(@_);
    $url =~ s!://!://\%s:x\@!;
    return sprintf $url, $self->api_key;
};

1;
