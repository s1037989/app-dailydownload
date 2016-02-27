package App::DailyDownload;
use Mojo::Base 'Mojolicious';

use App::DailyDownload::Assets;

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->plugin('PODRenderer');

  # Configuration
  $self->plugin('Config');
  $self->secrets($self->config('secrets'));

  $self->helper(assets => sub { App::DailyDownload::Assets->new(home => Mojo::Home->new(shift->app->home->rel_dir('public'))) });

  # Load Custom Plugins and Commands
  $self->plugin('Namespaces');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('assets#index')->name('index');

  # Assets by asset or by date
  #$r->get('/:date/:asset' => {date => 'today', asset => ''} => [date =~ qr/today|\d{4}\W?\d{2}\W?\d{2}/, asset =~ $self->assets])->to('assets#index');
  #$r->get('/:date' => [date =~ qr/today|\d{4}\W?\d{2}\W?\d{2}/])->to('assets#by_date');
  #$r->get('/:asset/:date' => {date => 'today', asset => ''} => [date =~ qr/today|\d{4}\W?\d{2}\W?\d{2}/, asset =~ $self->assets])->to('assets#index');
  #$r->get('/:asset' => [asset =~ $self->assets])->to('assets#by_asset');

  #$r->get('/by_date/:date/:asset' => [date => qr/\d{4}\W?\d{2}\W?\d{2}/, asset => $self->assets->monikers])->to('assets#by_date');
  #$r->get('/by_date/:date' => [date => qr/\d{4}\W?\d{2}\W?\d{2}/])->to('assets#by_date');
  #$r->get('/by_asset/:asset/:date' => [date => qr/\d{4}\W?\d{2}\W?\d{2}/, asset => $self->assets->monikers])->to('assets#by_asset');
  #$r->get('/by_asset/:asset' => [asset => $self->assets->monikers])->to('assets#by_asset');

  #$r->get('/by_date/:date')->to('assets#by_date');
  #$r->get('/by_asset/:asset')->to('assets#by_asset');

  $r->get('/:date' => {date => ''})->to('assets#by_date')->name('by_date');
  $r->get('/:asset/:end/:start' => {end => '', start => ''})->to('assets#by_asset')->name('by_asset');
}

1;
