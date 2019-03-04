use v6;
use Test;
use IO::Socket::Netlink::Raw :message;
use NativeCall;

plan *;

my $msg = nlmsg_alloc();
isa-ok $msg, nl_msg, <Create a message>;

lives-ok {nlmsg_free($msg)}, <Free a message>;

done-testing;

# vi:syntax=perl6
