use v6.d;
use IO::Socket::Netlink::Raw :socket, :message;
use NativeCall;

unit class IO::Socket::Netlink:ver<0.0.1> does IO::Socket is export;
has nl_sock $.sock; #allow access to raw methods

method port(UInt $port) { $!sock.set-local-port($port) }

submethod BUILD(Int :$protocol!, Int :$pid?, Int :$groups?) {
  $!sock .= new();
  unless $!sock ~~ nl_sock:D {
    $!sock = Failure.new("Could not allocate socket");
  }
  if $pid {
    $!sock.set-local-port($pid);
  }
  if $groups {
    $!sock.join-groups($groups);
  }
  if $!sock.connect($protocol) < 0 {
    $!sock = Failure.new("Could not connect socket");
  }
}


submethod TWEAK() {
  $!sock.disable-auto-ack;
  #$!port := port();
}

method close(\SELF --> Nil) {
  $!sock.close;
  $!sock.free;
  SELF = Nil;
}

method sockpid() returns Int {
  return $!sock.get-fd;
}

method new-message(NLMSG $type, NLM_F @flags ) returns nl_msg {
  nlmsg_alloc_simple($type, [+|] @flags);
}

method send-nlmsg(nl_msg:D $msg --> Int) {
  $!sock.complete-msg($msg);
  return $!sock.send($msg);
}

method send-ack(nlmsghdr $hdr) {
  say "send-ack";
  my $msg = nlmsg_alloc();
  # Append extends the message as needed without changing existing data.
  # To add the data on, declare a message with a payload of length 0, then
  # append to it.
  $msg.put($*PID, $hdr.seq, NLMSG::ERROR, nativesizeof(nlmsghdr), 0);


  # Error Code
  my nlmsgerr $buf .= new;
  $buf.error = 0;
  $buf.msg: $hdr;
  $msg.append(nativecast(Pointer[void], $buf), nativesizeof(nlmsgerr), 4);
  $!sock.send($msg);
}

method recv-nlmsg(Int $maxlen) returns nlmsghdr {
  my sockaddr_nl $addr .= new;
  my $p = Pointer.new;
  my ucred $ucred .= new;
  my $bytes = $!sock.recv($addr, $p, $ucred);
  return Failure.new("Could not read message") if $bytes < 0;
  return nativecast(Pointer[nlmsghdr], $p).deref;
}

method recv(Int $maxlen, :$ack) returns Pointer[void] {
  my nlmsghdr $msg = self.recv-nlmsg($maxlen);
  self.send-ack($msg) if $ack || $msg.flags +& NLM_F::ACK;
  return nativecast(Pointer[void], $msg.data);
}

method wait-for-ack() returns Int {
  return $!sock.wait-for-ack;
}

=begin pod

=head1 NAME

IO::Socket::Netlink - A Perl6 binding to and wrapper around libnl

=head1 SYNOPSIS

=begin code :lang<perl6>

use IO::Socket::Netlink;

=end code

=head1 DESCRIPTION

IO::Socket::Netlink allows communication over netlink sockets to 
and from the Linux kernel. It supports both the old and new methods
of group membership.

=head1 AUTHOR

Travis Gibson <TGib.Travis@protonmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Travis Gibson

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
