package EzyApp::Chargify::Client::Statements;
use Moose;

with
    'EzyApp::Chargify::Role::Client',
    'EzyApp::Chargify::Role::ClientBasicAuth';


=item single

return a statement by id

  $id = $statements->single($id);

=cut

sub single{
  my $self = shift;
  my $callback = pop if ref $_[-1] eq 'CODE';
  my ($id) = @_;
  my $url = $self->base_url. sprintf "/statements/$id.json";

  if ($callback){
    return $self->_request('get', $url, sub{
      my ($err, $sub) = @_;
      $callback->($err, $sub ? $sub->{statement} : undef);
    });
  } else {
    my $sub = $self->_request('get', $url);
    return $sub ? $sub->{statement} : undef;
  }

}

no Moose;
__PACKAGE__->meta->make_immutable;

