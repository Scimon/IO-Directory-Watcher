use v6.c;
use Test;
use IO::Directory::Watcher;
use File::Temp;

my $dir = tempdir();

ok $dir.path.d, "We have a temp directory";
my $test-file-path = "$dir/test-file".path;
my $fh = $test-file-path.open(:w);
$fh.say("Here's a line");

my $watcher = IO::Directory::Watcher.new( :dir($dir) );
my $event-channel = $watcher.supply.Channel();

$fh.say("Here's another line");
$fh.close();
# Small sleep to let the events catch up
sleep 0.25;

$watcher.done;

my @events = $event-channel.eager;
ok @events == 1, "We have 1 event";
my $event = @events[0];

is $event.type, IO::Directory::Watcher::Event::FileModified, "It's a file modification event";
is $event.path, "$dir/test-file".path, "For the file we modified";

done-testing;
