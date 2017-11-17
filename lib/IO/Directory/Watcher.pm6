use v6.c;
class IO::Directory::Watcher::Manifest {
    has IO::Path $.path;
}

class IO::Directory::Watcher::Event {
    enum EventType <FileCreated FileModified>;

    has EventType $.type;
    has IO::Path $.path;
}

class IO::Directory::Watcher:ver<0.0.1>:auth<Simon Proctor "simon.proctor@gmail.com"> {

    
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
            $!supplier.emit( IO::Directory::Watcher::Event.new( type => IO::Directory::Watcher::Event::FileModified, path => $event.path.IO ) );
        }
    }
    
    submethod BUILD( :$dir ) {
        fail "Directory required to watch" unless $dir;
        my $dir-path =  $dir ~~ Str ?? $dir.path !! $dir;
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

=head1 DESCRIPTION

IO::Directory::Watcher is a wrapper around the IO::Nofitication system designed to provide some addtional details for a long running process on changes made in a directory.

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
