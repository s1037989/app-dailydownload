package App::DailyDownload::Util;

use Mojo::Util;

# The Mojo::Util::md5_sum function only operates on bytes, so this is a wrapper
# function to allow a call to md5_sum to operate on a file.
sub md5_sum { return '' unless -e $_[0]; Mojo::Util::md5_sum Mojo::Util::slurp shift }

1;
