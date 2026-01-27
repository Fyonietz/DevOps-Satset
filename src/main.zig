const std = @import("std");
const progress = @import("progress.zig");
const helper = @import("help.zig");
const fmt = helper.IO;

pub fn main() !void {
    var std_in_buffer:[1024]u8 = undefined;
    var std_out_buffer:[1024]u8 = undefined;

    var stdout_file = std.fs.File.stdout().writer(&std_out_buffer);
    const stdout = &stdout_file.interface;
    
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&std_in_buffer);
    const stdin: *std.Io.Reader = &stdin_reader_wrapper.interface;
   
    // try progress.read_folder();
    try fmt.print(stdout,"Hello Test");

    try stdout.flush();
}


