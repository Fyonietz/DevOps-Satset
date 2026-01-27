const std = @import("std");

// Main build entry point
pub fn build(b: *std.Build) void {

    // Target (OS/arch) selection from `zig build`
    const target = b.standardTargetOptions(.{});

    // Optimization mode (Debug / ReleaseFast / etc.)
    const optimize = b.standardOptimizeOption(.{});

    // Public module definition
    const mod = b.addModule("Minit", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
    });

    // Executable definition
    const exe = b.addExecutable(.{
        .name = "Minit",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,

            // Import the public module into the executable
            .imports = &.{
                .{ .name = "Minit", .module = mod },
            },
        }),
    });
    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });

    // the executable from your call to b.addExecutable(...)
    exe.root_module.addImport("httpz", httpz.module("httpz"));
        // Install executable to zig-out/
    b.installArtifact(exe);

    // Custom build step: `zig build run`
    const run_step = b.step("run", "Run the app");

    // Run the built executable
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    // Ensure executable is installed before running
    run_cmd.step.dependOn(b.getInstallStep());

    // Forward CLI arguments: `zig build run -- arg1 arg2`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Tests for the public module
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    // Tests for the executable root module
    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_exe_tests = b.addRunArtifact(exe_tests);

    // Custom build step: `zig build test`
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}

