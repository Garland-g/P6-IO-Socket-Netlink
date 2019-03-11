use v6.d;
use NativeCall;

constant \LIB = 'nl-3';
constant \NL_AUTO_SEQ is export = 0;
constant \NL_AUTO_PID is export = 0;
constant \NL_AUTO_PORT is export = 0;
#constant \HELPER = %?RESOURCES<libraries/ui>;

enum NLMSG is export(:socket :message :enums) (
  NOOP => 0x1,
  ERROR => 0x2,
  DONE => 0x3,
  OVERRUN => 0x4,
  MIN_TYPE => 0x10,
);

enum NLM_F is export(:socket :message :enums)(
  REQUEST => 1,
  MULTI => 2,
  ACK => 4,
  ECHO => 8,
);

#Pointers, might change to struct later
class nl_sock is repr('CPointer') is export(:socket) {
  method new() {
    return nl_socket_alloc();
  }
  method free() {
    nl_socket_free(self);
  }
  method get-fd() {
    nl_socket_get_fd(self);
  }
  method get-local-port() returns uint32 {
    nl_socket_get_local_port(self);
  }
  method set-local-port(uint32 $port) {
    nl_socket_set_local_port(self, $port);
  }
  multi method port() returns uint32 {
    nl_socket_get_local_port(self);
  }
  multi method port(uint32 $port) {
    nl_socket_set_local_port(self, $port);
  }
}

class nlmsghdr is repr('CStruct') is export(:message) {
  has uint32 $.nlmsg-len is rw;
  has uint16 $.nlmsg-type is rw;
  has uint16 $.nlmsg-flags is rw;
  has uint32 $.nlmsg-seq is rw;
  has uint32 $.nlmsg-pid is rw;
}

class sockaddr_nl is repr('CPointer') is export(:socket) {}
class ucred is repr('CPointer') is export(:socket) {}

class nl_msg is repr('CPointer') is export(:message) {
  method free() {
    nlmsg_free(self)
  }
  method hdr() {
    nlmsg_hdr(self)
  }
  method append(Pointer[void] $data, size_t $len, int32 $pad) {
    nlmsg_append(self, $data, $len, $pad);
  }
  method size(int32 $len) {
    return nlmsg_size($len);
  }
  method enable-auto-ack() {
    nl_socket_enable_auto_ack(self);
  }
  method disable-auto-ack() {
    nl_socket_disable_auto_ack(self);
  }
  method set-nonblocking() {
    nl_socket_set_nonblocking(self);
  }
  method join-groups(int32 $groups) {
    nl_join_groups(self, $groups);
  }
  method add-membership(int32 $membership) {
    nl_socket_add_membership($membership);
  }
  method drop-membership(int32 $membership) {
    nl_socket_drop_membership($membership);
  }
  method connect(int32 $number) {
    nl_connect(self, $number);
  }
  method close() {
    nl_close(self);
  }
  method sendto(Pointer[void] $buf, size_t $size) {
    nl_sendto(self, $buf, $size);
  }
  method sendmsg(nl_msg $msg, nlmsghdr $hdr) returns int32 {
    nl_sendmsg(self, $msg, $hdr);
  }
  method send(nl_msg $msg) returns int32 {
    nl_send(self, $msg);
  }
  method complete-msg(nl_msg $msg) {
    nl_complete_msg(self, $msg);
  }
  method send-auto(nl_msg $msg) returns int32 {
    nl_send_auto(self, $msg);
  }
  method send-sync(nl_msg $msg) returns int32 {
    nl_send_sync(self, $msg);
  }
  method send-simple(nl_msg $msg) returns int32 {
    nl_send_simple(self, $msg);
  }
  method recv(sockaddr_nl $sockaddr is rw, Pointer $buf is rw, ucred $ucred is rw)  returns int32 {
    nl_recv(self, $sockaddr, $buf, $ucred);
  }
  method wait-for-ack() returns int32 {
    nl_wait_for_ack(self);
  }
}

#Sockets
sub nl_socket_alloc() returns nl_sock is native(LIB) is export(:socket) { * }
sub nl_socket_free(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_socket_get_fd(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_socket_get_local_port(nl_sock:D) returns uint32 is native(LIB) is export(:socket) { * }
sub nl_socket_set_local_port(nl_sock:D, uint32) is native(LIB) is export(:socket) { * }
sub nl_socket_enable_auto_ack(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_socket_disable_auto_ack(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_socket_set_nonblocking(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_join_groups(nl_sock:D, int32) is native(LIB) is export(:socket) { * }
sub nl_socket_add_membership(nl_sock:D, int32) returns int32 is export(:socket) { * }
sub nl_socket_drop_membership(nl_sock:D, int32) returns int32 is export(:socket) { * }
sub nl_socket_add_memberships(nl_sock:D, int32) returns int32 is export(:socket) { * }
sub nl_socket_drop_memberships(nl_sock:D, int32) returns int32 is export(:socket) { * }
sub nl_connect(nl_sock:D, int32) returns int32 is native(LIB) is export(:socket) { * }
sub nl_close(nl_sock:D) is native(LIB) is export(:socket) { * }
sub nl_sendto(nl_sock:D, Pointer[void], size_t) returns int32 is native(LIB) is export(:socket) { * }
sub nl_sendmsg(nl_sock:D, nl_msg:D, nlmsghdr:D) returns int32 is native(LIB) is export(:socket, :message) { * }
sub nl_send(nl_sock:D, nl_msg:D) returns int32 is native(LIB) is export(:socket, :message) { * }
sub nl_complete_msg(nl_sock:D, nl_msg:D) is native(LIB) is export(:socket, :message) { * }
sub nl_send_auto(nl_sock:D, nl_msg:D) returns int32 is native(LIB) is export(:socket, :message) { * }
sub nl_send_sync(nl_sock:D, nl_msg:D) returns int32 is native(LIB) is export(:socket, :message) { * }

sub nl_send_simple(nl_sock:D, int32, int32, Pointer[void], size_t) returns int32 is native(LIB) is export(:socket) { * }
sub nl_recv(nl_sock:D, sockaddr_nl is rw, Pointer is rw, ucred is rw) returns int32 is native(LIB) is export(:socket) { * }
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
