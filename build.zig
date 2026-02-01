const std = @import("std");

// Main build entry point
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Public module
    const mod = b.addModule("Minit", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
    });

    // Executable
    const exe = b.addExecutable(.{
        .name = "Minit",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "Minit", .module = mod },
            },
        }),
    });

    const httpz = b.dependency("httpz", .{ .target = target, .optimize = optimize });
    const tokamak = b.dependency("tokamak", .{ .target = target, .optimize = optimize });

    exe.root_module.addImport("httpz", httpz.module("httpz"));
    exe.root_module.addImport("tokamak", tokamak.module("tokamak"));
    exe.linkSystemLibrary("ssh");
    exe.linkLibC();

    // Set custom output path (root project directory)

    b.installArtifact(exe);

    // Custom run step
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Tests
    const mod_tests = b.addTest(.{ .root_module = mod });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{ .root_module = exe.root_module });
    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}


