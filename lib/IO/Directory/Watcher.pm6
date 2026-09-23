use v6.d;
class IO::Directory::Watcher::Manifest {
    has IO::Path $.path;
}

class IO::Directory::Watcher::Event {
    enum EventType <FileCreated FileModified FileDeleted>;

    has EventType $.type;
    has IO::Path $.path;
}

class IO::Directory::Watcher:ver<0.0.1>:auth<zef:Scimon> {

    
    subset ValidDirectory of IO::Path where *.d;
    
    has ValidDirectory $.dir;
    has Supply $.supply;
    has Supplier $!supplier;
    has Supply $!monitor;
    has IO::Directory::Watcher::Manifest %!manifest{Str};
    
    method !handle-event( $event ) {
        if ( ! %!manifest{$event.path} ) {
            $!supplier.emit( IO::Directory::Watcher::Event.new( type => IO::Directory::Watcher::Event::FileCreated, path => $event.path.IO ) );
            %!manifest{$event.path} = IO::Directory::Watcher::Manifest.new( path => $event.path.IO );
        } else {
            if ( ! $event.path.IO.e ) {
                %!manifest{$event.path} = Nil;
                $!supplier.emit( IO::Directory::Watcher::Event.new( type => IO::Directory::Watcher::Event::FileDeleted, path => $event.path.IO ) );
                return;
            } else {
                if ( $event.path.IO.d ) {
                    for ( %!manifest.keys ) -> $path {
                        if ( ! $path.IO.e ) {
                            %!manifest{$path} = Nil;
                            $!supplier.emit( IO::Directory::Watcher::Event.new( type => IO::Directory::Watcher::Event::FileDeleted, path => $path.IO ) );
                            return;
                        }
                    }
                }
                $!supplier.emit( IO::Directory::Watcher::Event.new( type => IO::Directory::Watcher::Event::FileModified, path => $event.path.IO ) );
            }
        }
    }
    
    submethod BUILD( :$dir ) {
        fail "Directory required to watch" unless $dir;
                    my $dir-path =  $dir ~~ Str ?? $dir.IO !! $dir;
        $!dir := $dir-path;
        $!supplier = Supplier.new;
        $!supply = $!supplier.Supply;
        %!manifest = self!init_manifest( $!dir );
        $!monitor = IO::Notification.watch-path( $!dir );
        $!monitor.tap( -> $e { self!handle-event( $e ) } );
    }

    method !init_manifest( $dir ) {
        my IO::Directory::Watcher::Manifest %manifest{Str};
        for dir( $dir ) -> $path {
            %manifest{$path.Str} = IO::Directory::Watcher::Manifest.new( path => $path );
        }
        return %manifest;
    }

    method done() {
        $!monitor = Nil;
        $!supplier.done();
    }
}


=begin pod

=head1 NAME

IO::Directory::Watcher - File change events for long running systems.

=head1 SYNOPSIS

  use IO::Directory::Watcher;
  $watcher = IO::Directory::Watcher.new( :dir(".") );
  $watcher.supply.tap( -> $event {
      if $event.type eq IO::Directory::Watcher::Event::FileCreated {
          say "File created: {$event.path}";
      } elsif $event.type eq IO::Directory::Watcher::Event::FileModified {
          say "File modified: {$event.path}";
      }
  });

=head1 DESCRIPTION

IO::Directory::Watcher is a wrapper around the IO::Nofitication system designed to provide some addtional details for a long running process on changes made in a directory.

A Directory Watcher is created with a directory path, either a path string or 
an IO::Path object, and will emit events when files or directories are created or 
modified in that directory. The events are emitted via a Supply which can be tapped 
into to receive the events.

Events are emitted as IO::Directory::Watcher::Event objects which contain the type of 
event and the path of the file or directory that was created, modified or deleted.

Currently the Watcher only supports a single directory and does not support 
recursive watching of sub-directories.

This has been tested on Linux and Windows. MacOS support is currently a work
in progress due to the handling of file change notifications on that platform.

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2026 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
