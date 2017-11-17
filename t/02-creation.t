use v6.c;
use Test;
use IO::Directory::Watcher;

dies-ok { IO::Directory::Watcher.new() }, "Needs to be given at least one valid directory";
dies-ok { IO::Directory::Watcher.new( :dir(Set(1,2,3)) ) }, "String or IO::Path only please";
dies-ok { IO::Directory::Watcher.new( :dir("./02-creation.t") ) }, "Needs to be a directory";
lives-ok { IO::Directory::Watcher.new( :dir(".") ) }, "Minimal creation works";
lives-ok { IO::Directory::Watcher.new( :dir(".".path) ) }, "Paths are fine";

my $watcher = IO::Directory::Watcher.new( :dir(".") );
ok $watcher.supply ~~ Supply, "The watcher has a supply";

my @events;

$watcher.supply.tap( -> $event { @events.push( $event ) } );

my $test-file-path = "./test-file".path;
$test-file-path.open(:w).say("Test");
$test-file-path.unlink;
# Small sleep to let the events catch up
sleep 1;

ok ! $test-file-path.e, "File deleted OK";
ok @events > 0, "We have some events";

done-testing;
