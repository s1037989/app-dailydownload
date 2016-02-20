package App::DailyDownload::Command::download;
use Mojo::Base 'Mojolicious::Command';

use Mojo::Loader qw(find_modules load_class);

has description => 'daily download';
has usage => sub { shift->extract_usage };

use Date::Simple;
use Date::Range;
use List::Collection;
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has assets => sub { [find_modules 'App::DailyDownload::Assets'] };

sub run {
  my ($self, @args) = @_;

  GetOptionsFromArray \@args,
    'asset|a=s' => \my @assets;

  die $self->usage unless @args <= 2;
  my $start = $args[0] ? Date::Simple->new($args[0]) : Date::Simple->new;
  my $end = $args[1] ? Date::Simple->new($args[1]) : $start;
  ref $start and $start->isa('Date::Simple') or $start = Date::Simple->new;
  ref $end and $end->isa('Date::Simple') or $end = Date::Simple->new;
  $end = Date::Simple->new if $end > Date::Simple->new;
  $start = $end if $start > $end;
  my $range = Date::Range->new($start, $end);
  printf "Range: %s => %s\n", $range->start, $range->end;
  for my $asset ( @assets ? intersect([map { "App::DailyDownload::Assets::$_" } @assets], $self->assets) : @{$self->assets} ) {
    my $e = load_class $asset;
    warn qq{Loading "$asset" failed: $e} and next if ref $e;
    foreach my $date ( $range->dates ) {
      $asset->new(date => $date, path => $self->path($date->as_d8))->download;
    }
  }
}

sub path { shift->app->home->rel_dir(join '/', 'public', @_) }

1;
