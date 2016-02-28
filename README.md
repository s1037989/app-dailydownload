# App::DailyDownload

App::DailyDownload is designed to retrieve *daily* downloads of *images*. It
can be made to work with less frequency, but, at this time, not with greater
frequency. It would be lovely to improve the handling of less frequency and
wonderful to improve the handling of greater frequency -- help is appreciated.

Also, tests and POD documentation are needed.

Also, some web design work on the templates would be nice.

## To install asset packages:

```
$ cpanm App::DailyDownload::Assets:X
```

...where X is the moniker of the package you wish to install.

## To capture daily downloads, set this in your system scheduler:

```
/path/to/app_daily_download download today 7
```

## To make the assets available via web:

```
$ /path/to/app_daily_download daemon
```

## The primary routes available are:

```
/
/:date
/:asset/:end/:start
```

`/` will provide an index page with links to the by_date route, where the date
is today.

`/:date` will provide all the installed assets on the specified date.

`/:asset/:end/:start` will provide the specified asset in the date range.
`start` can be either a date or a number for the number of days to include.

## Creating new plugins:

Each asset package should be its own package so that users can install only
those that they wish.

Some websites require a proper referer, so you might as well set that to the
initial page you'd go to if you were visiting it by hand.

Some websites requires a series of sequential visits, so the scrape attribute
is an arrayref of pairs: first the URL to visit and second the DOM to extract
the next step from. The final dom of the final pair should be a URL to the
final image which will be downloaded.

When it comes to something that has daily images to be downloaded, typically
one can access a specific date by specifying the date in the URL. As such,
the URL of the pair accepts format characters, same as L</strftime>. It also
accepts a special variable of L<$name> which will be replaced by the moniker
of the package.

```
package App::DailyDownload::Assets::baby_blues;
use Mojo::Base 'App::DailyDownload::Asset';

has name => 'Baby Blues';
has referer => 'http://www.babyblues.com/index.php';
has scrape => sub {[
  'http://www.babyblues.com/comics/%B-%-d-%Y' => sub { shift->dom->at("div#comicpanel img")->attr("src") },
]};

1;
```
