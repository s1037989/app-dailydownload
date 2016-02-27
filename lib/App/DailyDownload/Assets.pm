package App::DailyDownload::Assets;
use Mojo::Base -base;

use Mojo::Loader qw(find_modules load_class);

use Date::Simple::D8;
use Date::Range;
use List::Collection;

our $package = __PACKAGE__;

has home => sub { die "Required attribute home missing" };
has list_packages => sub { [&_packages] };
has list_monikers => sub { [map { /^.+::(\w+)$/; $1 } &_packages] };

sub list {
  my ($self, @assets) = @_;
  @assets ? intersect([map { "${package}::$_" } @assets], $self->list_packages) : @{$self->list_packages};
}

sub date_range {
  my ($self, $start, $end) = @_;
#  $start = $start ? Date::Simple::D8->new($start) : Date::Simple::D8->new;
#  $end = $end ? Date::Simple::D8->new($) : $start;
#  ref $start and $start->isa('Date::Simple::D8') or $start = Date::Simple::D8->new;
#  ref $end and $end->isa('Date::Simple::D8') or $end = Date::Simple::D8->new;
#  $end = Date::Simple::D8->new if $end > Date::Simple::D8->new;
#  $start = $end if $start > $end;
  $end = $end ? Date::Simple::D8->new($end) : Date::Simple::D8->new;
  if ( $start =~ /^\d{1,4}$/ ) {
    $start -= 1;
    $start = $end - $start;
  } else {
    $start = $start ? Date::Simple::D8->new($start) : Date::Simple::D8->new;
  }
  Date::Range->new($start, $end);
}

sub load {
  my ($self, $asset, $date) = @_;
  $asset = "${package}::$asset" unless $asset =~ /^$package/;
  my $e = load_class $asset;
  warn qq{Loading "$asset" failed: $e} and return if ref $e;
  $asset->new(home => $self->home, date => $date);
}

sub lookup_name {
  my ($self, $asset) = @_;
  $asset = "${package}::$asset" unless $asset =~ /^$package/;
  my $e = load_class $asset;
  warn qq{Loading "$asset" failed: $e} and return if ref $e;
  $asset->new->name;
}

sub _packages { find_modules $package }

1;
