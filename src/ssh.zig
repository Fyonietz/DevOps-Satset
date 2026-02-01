// ssh.zig
pub const c = @cImport({
    @cInclude("libssh/libssh.h");
});
