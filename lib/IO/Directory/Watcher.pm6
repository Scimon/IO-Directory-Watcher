use v6.c;
unit class IO::Directory::Watcher:ver<0.0.1>:auth<Simon Proctor "simon.proctor@gmail.com">;

subset ValidDirectory of Str where *.path.d;

has ValidDirectory $.dir;

submethod TWEAK( :$dir ) {
    fail "Directory required to watch" unless $dir;
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
