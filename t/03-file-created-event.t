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
# Small sleep to let the events catch up
sleep 0.25;

ok @events == 1, "We have 1 event";
ok @events[0].type == IO::Directory::Watcher::Event::FileCreated, "It's a file creation event";

done-testing;
