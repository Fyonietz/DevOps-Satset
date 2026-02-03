const std = @import("std");
const Model = @import("help.zig").Model;
pub const c = @cImport({
    @cInclude("libssh/libssh.h");
});
pub const Client = struct{
    session:c.ssh_session,
    allocator:std.mem.Allocator,

    pub fn exec(self:*Client,command:[]const u8)![]u8{
        const cmd_z = try self.allocator.dupeZ(u8,command);
        defer self.allocator.free(cmd_z);

        const channel = c.ssh_channel.new(self.session) orelse return error.ChannelCreateFailed;
        defer c.ssh_channel_free(channel);

        if(c.ssh_channel_open_session(channel)  != c.SSH_OK)
            return error.ChannelOpenFailed;

        if(c.ssh_channel_request_exec(channel,cmd_z)!=c.SSH_OK)
            return error.CommandFailed;

        var out = std.ArraList(u8).init(self.allocator);
        errdefer out.deinit();

        var buf:[256]u8 = undefined;
        while(true){
            const n = c.ssh_channel_read(channel,&buf,buf.len,0);
            if(n <= 0)break;
            try out.appendSlice(buf[0..@as(usize,@intCast(n))]);
        }
        _ = c.ssh_channel_send_eof(channel);
        _ = c.ssh_channel_close(channel);

        return out.toOwnedSlice();
    }
    pub fn disconnect(self:*Client)void{
        c.ssh_disconnect(self.session);
        c.ssh_free(self.session);
    }
};

var clients = std.AutoHashMap(u64,Client).init(std.heap.page_allocator);
var next_id:u64 = 1;


pub fn connect(allocator:std.mem.Allocator,model:Model.SSH)!u64{
    const c_address = try allocator.dupeZ(u8,model.address);
    defer allocator.free(c_address);

    const c_user = try allocator.dupeZ(u8,model.user);
    defer allocator.free(c_user);

    const c_password = try allocator.dupeZ(u8,model.password);
    defer allocator.free(c_password);

    const session = c.ssh_new() orelse return error.SessionCreateFailed;

    _ = c.ssh_options_set(session,c.SSH_OPTIONS_HOST,@as(*const anyopaque,@ptrCast(c_address)));
    
    _ = c.ssh_options_set(session,c.SSH_OPTIONS_USER,@as(*const anyopaque,@ptrCast(c_user)));

    if(c.ssh_connect(session)!=c.SSH_OK)
        return error.ConnectFailed;

    if(c.ssh_userauth_password(session,null,c_password)!=c.SSH_AUTH_SUCCESS)
        return error.AuthFailed;

    const id = next_id;
    next_id += 1;

    try clients.put(id,.{
        .session = session,
        .allocator = allocator
    });

    return id;
}
