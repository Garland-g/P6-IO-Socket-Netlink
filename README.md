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
# Many of the libnl subs are available as methods on their respective objects.
# This example is equivalent to the $socket.send example command
my $msg = $socket.new-message(NLMSG::DONE, :flags(NLM_F::REQUEST, NLM_F::ACK));
$msg.append($buf, $buf.bytes, 4); # calls nlmsg_append method from libnl
$socket.send-nlmsg($msg);
$socket.wait-for-ack();
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

### multi method new

```perl6
multi method new(
    Int :$protocol!,
    Int :$port,
    Int :$groups,
    :$auto-ack = Bool::True
) returns Mu
```

port is often the PID of the process

### multi method new

```perl6
multi method new(
    nl_sock :$sock
) returns Mu
```

Create a socket from a raw nl_sock

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

### multi method new-message

```perl6
multi method new-message() returns nl_msg
```

allocate a new message. Free with $msg.free().

### multi method new-message

```perl6
multi method new-message(
    NLMSG :$type,
    :@flags
) returns nl_msg
```

allocate a new message with the type and a list of flags.

### multi method new-message

```perl6
multi method new-message(
    NLMSG :$type,
    :$flags
) returns nl_msg
```

allocate a new message with the type and the flags

### multi method new-message

```perl6
multi method new-message(
    Int :$max where { ... }
) returns nl_msg
```

allocate a new message with a maximum payload size

### method send-nlmsg

```perl6
method send-nlmsg(
    nl_msg:D $msg
) returns Int
```

send a raw nl_msg (like nl_send_auto)

### multi method send

```perl6
multi method send(
    Buf[uint8] $buf,
    NLMSG :$type,
    :$flags
) returns Int
```

send a buf8 with the given type and flags

### multi method send

```perl6
multi method send(
    Buf[uint8] $buf,
    NLMSG :$type,
    :@flags
) returns Int
```

send a buf8 with the given type and a list of flags

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

