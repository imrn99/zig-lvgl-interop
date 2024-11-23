const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    var exe = b.addExecutable(.{
        .name = "lvgl-interop",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const liblvgl = try createLvglLibrary(b, target, optimize);
    exe.addIncludePath(b.path("lvgl"));

    exe.linkLibrary(liblvgl);

    const run_cmd = b.addRunArtifact(exe);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

// courtesy of https://x.com/selosallan/status/1858093937933615108

fn createLvglLibrary(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const cwd = std.fs.cwd();

    const liblvgl = b.addStaticLibrary(.{ .name = "lvgl", .target = target, .optimize = optimize });
    liblvgl.addIncludePath(b.path("lvgl"));

    liblvgl.linkLibC();
    // I'm linking to system SDL2 here because I use it for prototyping embed,
    // but you can also build SDL2 just like we're building LVGL atm
    liblvgl.linkSystemLibrary("SDL2");
    liblvgl.linkSystemLibrary("SDL2_image");

    const lvglDir = try cwd.openDir("lvgl/src", .{ .iterate = true });

    // Check if lv_conf.h exists, if not copy the template
    // I'm putting it in the root directory here to keep the lvgl submodule pure
    if (cwd.access("lv_conf.h", .{ .mode = .read_only }) == error.FileNotFound) {
        std.log.err("lv_conf.h doesn't exist, copying lvgl/lv_conf_template.h to ./lv_conf.h", .{});
        try cwd.copyFile("lvgl/lv_conf_template.h", cwd, "./lv_conf.h", .{});
    }

    var walker = try lvglDir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        const isCFile = std.mem.endsWith(u8, entry.basename, ".c");
        const isAssemblyFile = std.mem.endsWith(u8, entry.basename, ".S");

        if (entry.kind != .file or (!isCFile and !isAssemblyFile)) {
            continue;
        }

        const pathAlloc = try std.fmt.allocPrint(b.allocator, "lvgl/src/{s}", .{entry.path});
        defer b.allocator.free(pathAlloc);

        const path = b.path(pathAlloc);

        if (isAssemblyFile) {
            liblvgl.addAssemblyFile(path);
            continue;
        }

        liblvgl.addCSourceFile(.{ .file = path });
    }

    b.installArtifact(liblvgl);

    return liblvgl;
}
