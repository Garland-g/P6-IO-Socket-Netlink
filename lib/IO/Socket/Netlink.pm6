use v6.d;
use IO::Socket::Netlink::Raw :socket, :message;
use FINALIZER;
use NativeCall;

unit class IO::Socket::Netlink:ver<0.0.1> is export;
has &!unregister;
has nl_sock $!sock;
submethod BUILD() {
	$!sock = nl_socket_alloc();
	if nl_sock ~~ $!sock {
		$!sock = Failure.new("Could not allocate socket");
	}
}
submethod TWEAK() {
	&!unregister = FINALIZER.register: { .finalize with self };
}
method !close() {
	nl_socket_free($!sock);
	self = IO::Socket::Netlink;
}
method finalize(\SELF: --> Nil) {
	&!unregister();
	self!close();
	SELF = Nil;
}

=begin pod

=head1 NAME

IO::Socket::Netlink - blah blah blah

=head1 SYNOPSIS

=begin code :lang<perl6>

use IO::Socket::Netlink;

=end code

=head1 DESCRIPTION

IO::Socket::Netlink is ...

=head1 AUTHOR

Travis Gibson <TGib.Travis@protonmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Travis Gibson

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
