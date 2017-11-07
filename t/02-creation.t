use v6.c;
use Test;
use IO::Directory::Watcher;

dies-ok { IO::Directory::Watcher.new() }, "Needs to be given at least one valid directory";
lives-ok { IO::Directory::Watcher.new( :dir(".") ) }, "Minimal creation works";

done-testing;
