NAME
====

IO::Directory::Watcher - File change events for long running systems.

SYNOPSIS
========

    use IO::Directory::Watcher;
    $watcher = IO::Directory::Watcher.new( :dir(".") );
    $watcher.supply.tap( -> $event {
        if $event.type eq IO::Directory::Watcher::Event::FileCreated {
            say "File created: {$event.path}";
        } elsif $event.type eq IO::Directory::Watcher::Event::FileModified {
            say "File modified: {$event.path}";
        }
    });

DESCRIPTION
===========

IO::Directory::Watcher is a wrapper around the IO::Nofitication system designed to provide some addtional details for a long running process on changes made in a directory.

A Directory Watcher is created with a directory path, either a path string or an IO::Path object, and will emit events when files or directories are created or modified in that directory. The events are emitted via a Supply which can be tapped into to receive the events.

Events are emitted as IO::Directory::Watcher::Event objects which contain the type of event and the path of the file or directory that was created, modified or deleted.

Currently the Watcher only supports a single directory and does not support recursive watching of sub-directories.

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

