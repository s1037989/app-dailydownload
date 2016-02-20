package App::DailyDownload::Assets;
use Mojo::Base -base;

use Mojo::UserAgent;
use Mojolicious::Types;

#use App::DailyDownload::Util qw(md5_sum);
sub _md5_sum { shift; return '' unless -e $_[0]; Mojo::Util::md5_sum Mojo::Util::slurp shift }

use File::Basename;
use File::Path;
use Date::Simple::D8;

has ua => sub { Mojo::UserAgent->new->max_redirects(10) };
has types => sub { Mojolicious::Types->new };
has filename => sub { (ref shift) =~ /^.+::(\w+)$/; $1 };
has fullname => sub { join '/', $_[0]->path, $_[0]->filename };
has [qw(date path ext link)];
has days => sub { [] };
has min_size => 500;
has agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/31.0.1650.63 Chrome/31.0.1650.63 Safari/537.36';
has referer => 'http://www.google.com';
has headers => sub { {'User-Agent' => $_[0]->agent, 'Referer' => $_[0]->referer} };

sub download {
  my $self = shift;
  my $exists = ((glob($self->fullname.'.*'))[0]);
  return if $exists && -e $exists && time - ((stat($exists))[9]) < 3600;
  return if $exists && -s $exists > $self->min_size;
  my $size = $exists ? -s $exists : 0;
  # TODO: days attribute needs a starting date setting
  return if @{$self->days} && not grep { $_ eq (('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$self->date->day_of_week]) } @{$self->days};
  # Don't download an asset that's already been downloaded.
  # Compare HTTP timestamp, filename, md5sum, and/or size
  my $res;
  say sprintf "%s, %s", $self->name, $self->date;
  eval {
    foreach ( @{$self->crawl} ) {
      die if ref $res && $res->code != 200;
      $_ = $self->date->format(ref eq 'CODE' ? $res->$_ : $_);
      s/\$(\w+)/$self->$1/e;
      say "  Getting $_";
      $res = $self->ua->get($_ => $self->headers)->res;
    }
    # TODO: make sure $res contains a file, not HTML
    $self->ext((sort { length $a <=> length $b } @{$self->types->detect($res->headers->content_type)})[0]);
    my $asset = $res->content->asset;
    my $fullfile = join '/', $self->path, join('.', $self->filename, $self->ext);
    if ( $asset->size > $self->min_size ) {
      say sprintf "  Storing %s bytes in %s", $asset->size, $fullfile;
      mkpath dirname $fullfile unless -d dirname $fullfile ;
      $asset->move_to($fullfile);
    }
  };
  return $@;
}

1;
