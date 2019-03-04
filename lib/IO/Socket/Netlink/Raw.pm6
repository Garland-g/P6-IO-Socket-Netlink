use v6.d;
use NativeCall;

constant \LIB = 'nl-3';

class nl_sock is repr('CPointer') is export(:socket) {}
class nl_msg is repr('CPointer') is export(:message) {} 
class nlmsghdr is repr('CPointer') is export(:message) {}

sub nl_socket_alloc() returns nl_sock is native(LIB) is export(:socket) { * }
sub nl_socket_free(nl_sock) is native(LIB) is export(:socket) { * }
sub nl_socket_set_local_port(nl_sock, uint32) is native(LIB) is export(:socket) { * }

sub nlmsg_alloc() returns nl_msg is native(LIB) is export(:message) { * }
sub nlmsg_free(nl_msg) is native(LIB) is export(:message) { * }
sub nlmsg_data(nlmsghdr) returns Pointer[void] is native(LIB) is export(:message) { * }
