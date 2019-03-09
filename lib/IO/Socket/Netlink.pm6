use v6.d;
use IO::Socket::Netlink::Raw :socket, :message;
use NativeCall;

unit class IO::Socket::Netlink:ver<0.0.1> is export;
has nl_sock $!sock;

#Proxy setup
has $.auto-ack is rw;
#has $.port is rw;
#sub port() is rw {
#	Proxy.new:
#		FETCH => method () { nl_socket_get_local_port($!sock)},
#		STORE => method (UInt $port) {nl_socket_set_local_port($!sock, $port)};
#}

method port(UInt $port) {nl_socket_set_local_port($!sock, $port)}

sub auto-ack() is rw {
	my Bool $storage = True;
	Proxy.new:
		FETCH => method () { $storage},
		STORE => method (Bool $new) {
			$storage = $new;
			if $new {nl_socket_enable_auto_ack($!sock)}
			else {nl_socket_disable_auto_ack($!sock)}
		};
}

submethod BUILD(Int :$protocol!, Int :$pid?) {
	$!sock = nl_socket_alloc();
	if nl_sock ~~ $!sock {
		$!sock = Failure.new("Could not allocate socket");
	}
	if $pid {
		nl_socket_set_local_port($!sock, $pid);
	}
	if nl_connect($!sock, $protocol) < 0 {
		$!sock = Failure.new("Could not connect socket");	
	}
}
submethod TWEAK() {
	$!auto-ack := auto-ack();
	#$!port := port();
}

method close(\SELF --> Nil) {
	nl_close($!sock);
	nl_socket_free($!sock);
	SELF = Nil;
}

method sockpid() returns Int {
	return nl_socket_get_fd($!sock);
}

method new-message(NLMSG $type, NLM_F @flags ) returns nl_msg {
	nlmsg_alloc_simple($type, [+|] @flags);
}

method send-nlmsg(nl_msg:D $msg --> Int) {
	nl_complete_msg($!sock, $msg);
	return nl_send($!sock, $msg);
}

method recv-nlmsg(Int $maxlen) returns Pointer {
	my sockaddr_nl $addr .= new;
	my $buf = Pointer.new;
	my ucred $ucred .= new;
	nl_recv($!sock, $addr, $buf, $ucred);
	#send ACK
	my $msg = nlmsg_alloc_simple(NLMSG::ERROR, 0);
	nl_send_auto($!sock, $msg);
	nlmsg_free($msg);
	#end ACK
	return $buf;
}

method wait-for-ack() returns Int {
	nl_wait_for_ack($!sock);
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
