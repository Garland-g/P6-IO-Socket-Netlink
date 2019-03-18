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
my $msg = $socket.new-message(NLMSG::DONE, (NLM_F::REQUEST, NLM_F::ACK));
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

