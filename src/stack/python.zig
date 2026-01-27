const std = @import("std");
const h = @import("../help.zig");

pub fn run() void{
    try h.IO.clearScreen();
    std.debug.print("Use Python\n",.{});
}
