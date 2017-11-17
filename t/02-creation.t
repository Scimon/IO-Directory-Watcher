use v6.c;
use Test;
use IO::Directory::Watcher;
use File::Temp;
plan 12;

dies-ok { IO::Directory::Watcher.new() }, "Needs to be given at least one valid directory";
dies-ok { IO::Directory::Watcher.new( :dir(Set(1,2,3)) ) }, "String or IO::Path only please";
dies-ok { IO::Directory::Watcher.new( :dir("./02-creation.t") ) }, "Needs to be a directory";
lives-ok { IO::Directory::Watcher.new( :dir(".") ) }, "Minimal creation works";
lives-ok { IO::Directory::Watcher.new( :dir(".".path) ) }, "Paths are fine";

my $dir = tempdir();
ok $dir.path.d, "We have a temp directory";

my $watcher = IO::Directory::Watcher.new( :dir($dir.path) );
ok $watcher.supply ~~ Supply, "The watcher has a supply";

my $event-channel = $watcher.supply.Channel();

my $test-file-path = "$dir/test-file".path;
ok ! $test-file-path.e, "No File";
my $fh = $test-file-path.open(:w);
ok $test-file-path.e, "File Created";
$fh.say("Test");
ok $test-file-path.e, "File still there";
$fh.close;
ok $test-file-path.e, "File closed OK";
$test-file-path.unlink;

sleep 0.25;

$watcher.done;

my Int $count = 0;
for $event-channel.list -> $e {
    $count++;
}

ok $count > 0, "We have some events";
