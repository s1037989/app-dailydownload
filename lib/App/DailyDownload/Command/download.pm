package App::DailyDownload::Command::download;
use Mojo::Base 'Mojolicious::Command';

has description => 'daily download';
has usage => sub { shift->extract_usage };

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

sub run {
  my ($self, @args) = @_;

  GetOptionsFromArray \@args,
    'asset|a=s' => \my @assets;

  die $self->usage unless @args <= 2;
  my $range = $self->app->assets->date_range(@args);
  printf "Range: %s => %s\n", $range->start, $range->end;

  # Foreach asset (those specified, or all found); then foreach date in the range
  foreach my $asset ( $self->app->assets->list(@assets) ) {
    foreach my $date ( $range->dates ) {
      $self->app->assets->load($asset => $date)->download;
    }
  }
}

1;
