use v6.d;
use NativeCall;

constant \LIB = 'nl-3';

#Pointers, might change to struct later
class nl_sock is repr('CPointer') is export(:socket) {}
class nl_msg is repr('CPointer') is export(:message) {}
class nlmsghdr is repr('CPointer') is export(:message) {}
class sockaddr_nl is repr('CPointer') is export(:socket) {}
class ucred is repr('CPointer') is export(:socket) {}


#Sockets
sub nl_socket_alloc() returns nl_sock is native(LIB) is export(:socket) { * }
sub nl_socket_free(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_socket_set_local_port(nl_sock:D, uint32) is native(LIB) is export(:socket) { * }
sub nl_connect(nl_sock:D, int32) returns int32 is native(LIB) is export(:socket) { * }
sub nl_close(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_sendto(nl_sock:D, Pointer[void], size_t) returns int32 is native(LIB) is export(:socket) { * }
sub nl_sendmsg(nl_sock:D, nl_msg:D, nlmsghdr:D) returns int32 is native(LIB) is export(:socket, :message) { * }
sub nl_send(nl_sock:D, nl_msg:D) returns int32 is native(LIB) is export(:socket, :message) { * }
sub nl_complete_msg(nl_sock:D, nl_msg:D) is native(LIB) is export(:socket, :message) { * }
sub nl_send_auto(nl_sock:D, nl_msg:D) returns int32 is native(LIB) is export(:socket, :message) { * }
sub nl_send_sync(nl_sock:D, nl_msg:D) returns int32 is native(LIB) is export(:socket, :message) { * }

sub nl_send_simple(nl_sock:D, int32, int32, Pointer[void], size_t) returns int32 is native(LIB) is export(:socket) { * }
sub nl_recv(nl_sock:D, sockaddr_nl, Pointer[Str], Pointer[ucred]) returns int32 is native(LIB) is export(:socket) { * }
sub nl_wait_for_ack(nl_sock:D) returns int32 is native(LIB) is export(:socket) { * }

#Messages
sub nlmsg_alloc() returns nl_msg is native(LIB) is export(:message) { * }
sub nlmsg_alloc_size(size_t) returns nl_msg is native(LIB) is export(:message) { * }
sub nlmsg_alloc_simple(int32, int32) returns nl_msg is native(LIB) is export(:message) { * }
sub nlmsg_free(nl_msg:D) is native(LIB) is export(:message) { * }
sub nlmsg_size(int32) returns int32 is native(LIB) is export(:message) { * }
sub nlmsg_total_size(int32) returns int32 is native(LIB) is export(:message) { * }
sub nlmsg_set_default_size(size_t) is native(LIB) is export(:message) { * }
sub nlmsg_padlen(int32) returns int32 is native(LIB) is export(:message) { * }
sub nlmsg_data(nlmsghdr:D) returns Pointer[void] is native(LIB) is export(:message) { * }
sub nlmsg_datalen(nlmsghdr:D) returns int32 is native(LIB) is export(:message) { * }
#sub nlmsg_tail(nlmsghdr:D) returns Pointer[void] is native(LIB) is export(:message) { * } #Does this exist?

sub nlmsg_inherit(nlmsghdr:D) returns nl_msg is native(LIB) is export(:message) { * }
sub nlmsg_convert(nlmsghdr:D) returns nl_msg is native(LIB) is export(:message) { * }
sub nlmsg_reserve(nl_msg:D, size_t, int32) returns Pointer[void] is native(LIB) is export(:message) { * }
sub nlmsg_append(nl_msg:D, Pointer[void], size_t, int32) returns int32 is native(LIB) is export(:message) { * }
sub nlmsg_expand(nl_msg:D, size_t) returns int32 is native(LIB) is export(:message) { * }
sub nlmsg_put(nl_msg:D, uint32, uint32, int32, int32, int32) returns nlmsghdr is native(LIB) is export(:message) { * }
sub nlmsg_hdr(nl_msg:D) returns nlmsghdr is native(LIB) is export(:message) { * }
sub nlmsg_get(nl_msg:D) is native(LIB) is export(:message) { * }
#sub nl_msg_dump(nl_msg:D, FILE desc) is native(LIB) is export(:message) { * }
