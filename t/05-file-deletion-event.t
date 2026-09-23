use v6.d;
use Test;
use IO::Directory::Watcher;
use File::Temp;

my $dir = tempdir();

ok $dir.IO.d, "We have a temp directory";
my $test-file-path = "$dir/test-file".IO;
my $fh = $test-file-path.open(:w);
$fh.say("Here's a line");
$fh.close();

my $watcher = IO::Directory::Watcher.new( :dir($dir) );
my $event-channel = $watcher.supply.Channel();

$test-file-path.unlink;

sleep 0.25;

$watcher.done;

my @events = $event-channel.eager;
ok @events == 1, "We have 1 event";
my $event = @events[0];

is $event.type, IO::Directory::Watcher::Event::FileDeleted, "It's a file deletion event";
is $event.path, ($dir,'test-file').join($*SPEC.dir-sep).IO, "For the file we deleted";

done-testing;
