package App::DailyDownload::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';

use Date::Simple::D8;

sub index {
  my $self = shift;
  $self->render(today => Date::Simple::D8->new);
}

sub by_date {
  my $self = shift;
  my $date = $self->param('date') ? Date::Simple::D8->new($self->param('date')) : Date::Simple::D8->new;
  $self->render(date => $date);
}

sub by_asset {
  my $self = shift;
  $self->render(asset => $self->param('asset'), date_range => $self->assets->date_range($self->param('start') => $self->param('end')));
}

1;
