use v6.c;
use Test;
use IO::Directory::Watcher;

dies-ok { IO::Directory::Watcher.new() }, "Needs to be given at least one valid directory";
dies-ok { IO::Directory::Watcher.new( :dir("./02-creation.t") ) }, "Needs to be a directory";
lives-ok { IO::Directory::Watcher.new( :dir(".") ) }, "Minimal creation works";

done-testing;
