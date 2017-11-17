use v6.c;
use Test;
use IO::Directory::Watcher;
use File::Temp;

my $dir = tempdir();

ok $dir.path.d, "We have a temp directory";

my $watcher = IO::Directory::Watcher.new( :dir($dir) );

my $event-channel = $watcher.supply.Channel();


my $test-file-path = "$dir/test-file".path;
$test-file-path.open(:w);
# Small sleep to let the events catch up
sleep 0.25;

$watcher.done;

my @events = $event-channel.eager;
ok @events == 1, "We have 1 event";
my $event = @events[0];

is $event.type, IO::Directory::Watcher::Event::FileCreated, "It's a file creation event";
is $event.path, "$dir/test-file".path, "For the file we created";

done-testing;
