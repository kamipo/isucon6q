#!/usr/bin/env plackup
use 5.014;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use File::Spec;
use Plack::Builder;

use Isuda::Web;

my $root_dir = $FindBin::Bin;
my $app = Isuda::Web->psgi($root_dir);
builder {
    enable 'ReverseProxy';
    enable 'Static',
        path => qr!^/(?:(?:css|js|img)/|favicon\.ico$)!,
        root => File::Spec->catfile($root_dir, 'public');
    enable 'Session::Cookie',
        session_key => "isuda_session",
        secret      => 'tonymoris';

#    enable 'Profiler::NYTProf',
#        enable_profile       => sub { $$ % 2 == 0 },
#        env_nytprof          => 'start=no:addpid=0:file=/dev/null',
#        profiling_result_dir => sub { '/tmp/profile' },
#        enable_reporting     => 1;
    $app;
};
