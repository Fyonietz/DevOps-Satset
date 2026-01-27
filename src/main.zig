const std = @import("std");
const httpz = @import("httpz");

const PORT = 8801;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var server = try httpz.Server(void).init(allocator, .{
        .port = PORT,
        .request = .{
            .max_form_count = 20,
        },
    }, {});
    defer server.deinit();
    defer server.stop();

    var router = try server.router(.{});

    router.get("/", index, .{});
    router.post("/form_data", formPost, .{});

    std.debug.print("listening http://localhost:{d}/\n", .{PORT});
    try server.listen();
}

fn index(_: *httpz.Request, res: *httpz.Response) !void {
    res.body = "Hello from GET route";
}

fn formPost(req: *httpz.Request, res: *httpz.Response) !void {
    var it = (try req.formData()).iterator();

    res.content_type = .TEXT;
    const w = res.writer();

    while (it.next()) |kv| {
        try w.print("{s}={s}\n", .{ kv.key, kv.value });
    }
}



