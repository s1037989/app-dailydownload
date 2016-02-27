package App::DailyDownload::Util;

use Mojo::Util;

sub md5_sum { return '' unless -e $_[0]; Mojo::Util::md5_sum Mojo::Util::slurp shift }

1;
