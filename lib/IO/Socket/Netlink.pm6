use v6.d;

=begin pod

=head1 NAME

IO::Socket::Netlink - A Perl6 binding to and wrapper around libnl

=head1 SYNOPSIS

=begin code :lang<perl6>

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

=end code

=head1 DESCRIPTION

IO::Socket::Netlink allows communication over netlink sockets to and from the Linux kernel. It supports both the old and new methods of group membership.

This module does not implement any particular protocol of netlink. Instead it provides a basis for other modules implementing netlink protocols to build off of.

This module uses OO::Monitors.

=head1 AUTHOR

Travis Gibson <TGib.Travis@protonmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Travis Gibson

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The underlying library in use is libnl-3, which is LGPL v2.1.

=head1 DOCS

=end pod

use IO::Socket::Netlink::Raw :socket, :message;
use OO::Monitors;
use NativeCall;

unit monitor IO::Socket::Netlink:ver<0.0.1> does IO::Socket is export;
has nl_sock $.sock;

method port(UInt $port) { $!sock.set-local-port($port) }
#= Set the port of the socket

multi submethod BUILD(Int :$protocol!, Int :$port?, Int :$groups?, :$auto-ack?) {
  $!sock .= new();
  unless $!sock ~~ nl_sock:D {
    $!sock = Failure.new("Could not allocate socket");
  }
  if $port {
    $!sock.set-local-port($port);
  }
  if $groups {
    $!sock.join-groups($groups);
  }
  if $!sock.connect($protocol) < 0 {
    $!sock = Failure.new("Could not connect socket");
  }
  $!sock.disable-auto-ack unless $auto-ack;
}
#= port is often the PID of the process

multi submethod BUILD(nl_sock :$!sock) {}
#= Create a socket from a raw nl_sock

method !Nil(\SELF) returns Nil {
  SELF = Nil;
}

#| returns Nil
method close() returns Nil {
  $!sock.close;
  $!sock.free;
  self!Nil;
}
#= Close a socket and free it. The socket becomes Nil.

#| returns Int
method sockpid() returns Int {
  return $!sock.get-fd;
}
#= get the file descriptor

#| returns nl_msg
multi method new-message() returns nl_msg {
  nl_msg.new();
}
#= allocate a new message. Free with $msg.free().

#| returns nl_msg
multi method new-message(NLMSG :$type, :@flags ) returns nl_msg {
  self.new-message(:$type, :flags([+|] @flags));
}
#= allocate a new message with the type and a list of flags.

#| returns nl_msg
multi method new-message(NLMSG :$type, :$flags ) returns nl_msg {
  nl_msg.new(:$type, :$flags);
}
#= allocate a new message with the type and the flags

#| returns nl_msg
multi method new-message(UInt :$max) returns nl_msg {
  nl_msg.new($max);
}
#= allocate a new message with a maximum payload size

#| returns Int
method send-nlmsg(nl_msg:D $msg) returns Int {
  $!sock.complete-msg($msg);
  return $!sock.send($msg);
}
#= send a raw nl_msg (like nl_send_auto)

#| returns Int
multi method send(buf8 $buf, NLMSG :$type, :$flags) returns Int {
  my $msg = self.new-message(:$type, :$flags);
  $msg.append(nativecast(Pointer[void], $buf), $buf.bytes, 4);
  self.send-nlmsg($msg);
  $!sock.wait-for-ack() if $flags +| NLM_F::ACK;
}
#= send a buf8 with the given type and flags

#| returns Int
multi method send(buf8 $buf, NLMSG :$type, :@flags) returns Int {
  self.send($buf, :$type, :flags([+|] @flags));
}
#= send a buf8 with the given type and a list of flags

#| returns Int
method send-ack(nlmsghdr $hdr) returns Int {
  my $msg = nlmsg_alloc();
  $msg.put($*PID, $hdr.seq, NLMSG::ERROR, nativesizeof(nlmsghdr), 0);

  my nlmsgerr $buf .= new;
  $buf.error = 0;
  $buf.msg: $hdr;
  $msg.append(nativecast(Pointer[void], $buf), nativesizeof(nlmsgerr), 4);

  $!sock.send($msg);
}
#= send an acknowledgement message for a given header

#| returns nlmsghdr
method recv-nlmsg(Int $maxlen) returns nlmsghdr {
  my sockaddr_nl $addr .= new;
  my $p = Pointer.new;
  my ucred $ucred .= new;
  my $bytes = $!sock.recv($addr, $p, $ucred);
  return Failure.new("Could not read message") if $bytes < 0;
  return nativecast(Pointer[nlmsghdr], $p).deref;
}
#= receive a raw nlmsg as an nlmsghdr

#| returns Pointer[void]
method recv(Int $maxlen, :$ack) returns Pointer[void] {
  my nlmsghdr $msg = self.recv-nlmsg($maxlen);
  self.send-ack($msg) if $ack || $msg.flags +& NLM_F::ACK;
  return nativecast(Pointer[void], $msg.data);
}
#= receive a message and get a Pointer to its contents

#| returns Int
method wait-for-ack() returns Int {
  return $!sock.wait-for-ack;
}
#= wait for an acknowledgement message
