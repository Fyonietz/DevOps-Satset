const std = @import("std");
const progress = @import("progress.zig");
const helper = @import("help.zig");
const fmt = helper.IO;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var stack =try helper.Stack.init(&allocator);
    defer stack.deinit();
    
    try stack.put("python",helper.Stack.run.Python);

    var read_buf: [512]u8 = undefined;
    // get a real File.Reader for stdin
    const stdin_reader = std.fs.File.stdin().reader(&read_buf);

    // wrap
    var wrapped = fmt.init(stdin_reader);

    // get the interface pointer
    const reader: *std.Io.Reader = wrapped.interface();

    var out_buf: [128]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&out_buf);
    const writer: *std.Io.Writer = &stdout_writer.interface;

    try writer.writeAll("Type something:");
    try writer.flush();

    // read until newline
    var condition = true;
    var output:[]const u8 = "";
    while (condition) {
        const line = reader.takeDelimiterExclusive('\n') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        // consume the delimiter
        reader.toss(1);

        // use `line`
        output = line;
        condition = false;
    }

    try writer.print("You Type:{s}",.{output});
    stack.call(output);
    try writer.flush();
}

