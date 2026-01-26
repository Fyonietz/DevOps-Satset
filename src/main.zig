const command = @import("help.zig");


pub fn main() !void {
    try command.init();
}


