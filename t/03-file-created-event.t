use v6.c;
use Test;
use IO::Directory::Watcher;
use File::Temp;

my $dir = tempdir();
my @events;

ok $dir.path.d, "We have a temp directory";

my $watcher = IO::Directory::Watcher.new( :dir($dir) );
$watcher.supply.tap( -> $event { @events.push( $event ) } );

my $test-file-path = "$dir/test-file".path;
$test-file-path.open(:w).say("Test");
$test-file-path.unlink;
# Small sleep to let the events catch up
sleep 0.25;

ok ! $test-file-path.e, "File deleted OK";
#ok @events == 1, "We have an event";

done-testing;
