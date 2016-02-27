package App::DailyDownload::Asset;
use Mojo::Base -base;

use Mojo::UserAgent;
use Mojolicious::Types;
use Mojo::Util qw(spurt);
use Mojo::Loader qw(data_section);

use App::DailyDownload::Util;

use File::Spec::Functions qw(abs2rel catfile);
use File::Basename;
use File::Path;

has ua => sub { Mojo::UserAgent->new->max_redirects(10) };
has types => sub { Mojolicious::Types->new };

# Attributes of the asset
has moniker => sub { (ref shift) =~ /^.+::(\w+)$/; $1 };
has home => sub { die "No home provided to asset" };
has date => sub { die "No date provided to asset" };
has min_size => 500;
has ext => sub { ((split /\./, ((glob(join '.', shift->_filename, '*'))[0]))[-1]) || '' };
has _filename => sub {
  my $self = shift;
  $self->home->rel_file(catfile $self->date, $self->moniker);
};

# Attributes necessary for downloading
has agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/31.0.1650.63 Chrome/31.0.1650.63 Safari/537.36';
has referer => 'http://www.google.com';
has headers => sub { {'User-Agent' => $_[0]->agent, 'Referer' => $_[0]->referer} };

sub filename {
  my $self = shift;
  join '.', $self->_filename, $self->ext if $self->ext;
}
sub img {
  my $self = shift;
  return unless $self->filename;
  '/'.abs2rel($self->filename, $self->home);
}

sub md5_sum { App::DailyDownload::Util::md5_sum shift->filename }

sub download {
  my $self = shift;
  return if $self->filename && -e $self->filename;
  my $res;
  say sprintf "%s, %s", $self->moniker, $self->date;
  eval {
    foreach ( @{$self->scrape} ) {
      die if ref $res && $res->code != 200;
      $_ = $self->date->format(ref eq 'CODE' ? $res->$_ : $_);
      s/\$(\w+)/$self->$1/e;
      say "  Getting $_";
      $res = $self->ua->get($_ => $self->headers)->res;
    }
    # TODO: make sure $res contains a file, not HTML
    my $asset = $res->content->asset;
    $self->ext((sort { length $a <=> length $b } @{$self->types->detect($res->headers->content_type)})[0]);
    die if $asset->size < $self->min_size;
    die unless $self->diff($self->date - 1);
    say sprintf "  Storing %s bytes in %s", $asset->size, $self->filename;
    mkpath dirname $self->filename unless -d dirname $self->filename;
    $asset->move_to($self->filename);
  };
  if ( $@ ) {
    $self->ext('png');
    spurt data_section(__PACKAGE__, 'not_found.png'), $self->filename;
    return $@;
  } else {
    return undef;
  }
}

sub diff {
  my ($self, $date) = @_;
  return 1;
  my $class = ref $self;
  $class->new(date => $date)->md5_sum != $self->md5_sum;
}

1;

__DATA__
@@ not_found.png
abc