package App::DailyDownload;
use Mojo::Base 'Mojolicious';

use App::DailyDownload::Assets;

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->helper(assets => sub {
    App::DailyDownload::Assets->new(home => Mojo::Home->new(shift->app->home->rel_dir('public')))
  });

  # Load Custom Plugins and Commands
  $self->plugin('Namespaces');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('assets#index')->name('index');

  # TODO: validate these placeholders
  $r->get('/:date' => {date => ''})->to('assets#by_date')->name('by_date');
  $r->get('/:asset/:end/:start' => {end => '', start => ''})->to('assets#by_asset')->name('by_asset');
}

1;
