const std = @import("std");
const tk = @import("tokamak");
const ssh = @import("ssh.zig");

pub const Model = struct {
    pub const SSH = struct {
        address: []const u8,
        user:[]const u8,
        password: []const u8,
        port: u32,
    };
    pub const SSH_ID = struct{
        id:u64,
        command:[]const u8
    };
};

pub const API = struct {
    pub fn @"GET /home"() []const u8 {
        return "hello from home";
    }
    
    pub const SSH = struct {
        pub fn @"POST /connect"(
            allocator: std.mem.Allocator,
            body: Model.SSH
        ) !struct { 
            id:u64,
            message:[]const u8,
        } {
           const id = try ssh.connect(
               allocator,
                 body
            );

           return .{ .id = id, .message = "Connected" };
        }
        
        pub fn @"GET /test"() []const u8 {
            return "test from ssh";
        }
    };
};


