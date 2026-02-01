const std = @import("std");
const tk = @import("tokamak");

pub const Model = struct {
    pub const SSH = struct {
        address: []const u8,
        password: []const u8,
        port: u32,
    };
};

pub const API = struct {
    pub fn @"GET /home"() []const u8 {
        return "hello from home";
    }
    
    pub const SSH = struct {
        // Body parameter is LAST - Tokamak auto-parses JSON
        pub fn @"POST /connect"(body: Model.SSH) !struct { 
            message: []const u8, 
            out: []const u8 
        } {
            std.debug.print("SSH Connection to: {s}:{d}\n", .{
                body.address,
                body.port
            });
            
            // Your SSH connection logic here
            
            return .{
                .message = "Connected",
                .out = body.address
            };
        }
        
        pub fn @"GET /test"() []const u8 {
            return "test from ssh";
        }
    };
};


