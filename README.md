NAME
====

IO::Socket::Netlink - A Perl6 binding to and wrapper around libnl

SYNOPSIS
========

```perl6
use IO::Socket::Netlink;
use IO::Socket::Netlink::Raw :enums :constants;
# access to useful enums and constants (probably what you want)

# use IO::Socket::Netlink::Raw :message
# access to raw message methods, objects, and message components
# use IO::Socket::Netlink::Raw :socket
# access to raw socket methods and object

my $protocol = 31;
my $socket = IO::Socket::Netlink.new(:$protocol);

# Send a message on the socket
my buf8 $buf .= new(16);
$socket.send($buf, :type(NLMSG::DONE), :flags(NLM_F::REQUEST, NLM_F::ACK));

# For more control, see the new-message, send-nlmsg, and recv-nlmsg methods.
```

DESCRIPTION
===========

IO::Socket::Netlink allows communication over netlink sockets to and from the Linux kernel. It supports both the old and new methods of group membership.

This module does not implement any particular protocol of netlink. Instead it provides a basis for other modules implementing netlink protocols to build off of.

This module uses OO::Monitors.

AUTHOR
======

Travis Gibson <TGib.Travis@protonmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 Travis Gibson

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The underlying library in use is libnl-3, which is LGPL v2.1.

DOCS
====

### method port

```perl6
method port(
    Int $port where { ... }
) returns Mu
```

Set the port of the socket

### method close

```perl6
method close() returns Nil
```

Close a socket and free it. The socket becomes Nil.

### method sockpid

```perl6
method sockpid() returns Int
```

get the file descriptor

### method send-nlmsg

```perl6
method send-nlmsg(
    nl_msg:D $msg
) returns Int
```

send a raw nl_msg (like nl_send_auto)

### method send-ack

```perl6
method send-ack(
    nlmsghdr $hdr
) returns Int
```

send an acknowledgement message for a given header

### method recv-nlmsg

```perl6
method recv-nlmsg(
    Int $maxlen
) returns nlmsghdr
```

receive a raw nlmsg as an nlmsghdr

### method recv

```perl6
method recv(
    Int $maxlen,
    :$ack
) returns NativeCall::Types::Pointer[NativeCall::Types::void]
```

receive a message and get a Pointer to its contents

### method wait-for-ack

```perl6
method wait-for-ack() returns Int
```

wait for an acknowledgement message

