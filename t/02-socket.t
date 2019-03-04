use v6;
use Test;
use IO::Socket::Netlink::Raw :socket;
use NativeCall;

plan *;

my $sock = nl_socket_alloc();
isa-ok $sock, nl_sock, <Create a socket>;

lives-ok {nl_socket_free($sock)}, <Free a socket>;

done-testing;

# vi:syntax=perl6
