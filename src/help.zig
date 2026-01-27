const std = @import("std");
const python = @import("stack/python.zig");
// A simple Reader wrapper
pub const IO = struct {
    // concrete reader backing storage
    reader_impl: std.fs.File.Reader,  // could be any concrete reader type

    // expose the interface
    pub const Reader = std.Io.Reader;

    pub fn init(reader: std.fs.File.Reader) IO {
        return IO{ .reader_impl = reader };
    }

    // get pointer to the interface
    pub fn interface(self: *IO) *std.Io.Reader {
        return &self.reader_impl.interface;
    }

    pub fn clearScreen() !void{
        std.debug.print("\x1b[2J\x1b[H",.{});
    }
};

pub const Stack = struct{
    const FuncType = *const fn() void;
    allocator:*std.mem.Allocator,
    map:std.StringHashMap(FuncType),
    pub const run = struct{
        pub fn Python() void{
           python.run();
        }
        pub fn NodeJS() void{
        std.debug.print("Use NodeJS\n",.{});
        }
        pub fn CSharp() void{
        std.debug.print("Use CSharp\n",.{});
        }
        pub fn Binary() void{
        std.debug.print("Use Binary\n",.{});
        }
    };

    pub fn init(allocator:*std.mem.Allocator)!Stack{
        return Stack{.allocator=allocator,.map=std.StringHashMap(FuncType).init(allocator.*),};
    }
    pub fn put(self:*Stack,key:[]const u8,func:FuncType)!void{
        try self.map.put(key,func);
    }
    pub fn call(self:*Stack,key:[]const u8)void{
        if(self.map.get(key)) |f|{
            f();
        }else{
            std.debug.print("Stack Not Registered:{s}\n",.{key});
        }
    }
    pub fn deinit(self: *Stack) void {
        self.map.deinit();
    }
};


