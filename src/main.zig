const std = @import("std");
const API = @import("help.zig").API;
const tk = @import("tokamak");
const PORT = 8080;

const routes: []const tk.Route = &.{
    tk.static.dir("src/static", .{}),
    .get("/", tk.static.file("src/static/index.html")),
    
    // Different scopes for different API groups
    .group("/api", &.{
        tk.logger(.{.scope = .rest_api}, &.{
            .router(API)
        })
    }),
    
    .group("/api/ssh", &.{
        tk.logger(.{.scope = .ssh_api}, &.{
            .router(API.SSH)
        })
    })
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    
    var server = try tk.Server.init(allocator, routes, .{ .listen = .{ .port = PORT } });
    std.debug.print("Server Started At:http://localhost:{d}\n",.{PORT});
    try server.start();
}




