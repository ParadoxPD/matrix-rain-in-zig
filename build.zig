const std = @import("std");

pub fn build(b: *std.Build) void {

    //Build Target
    const windows = b.option(bool, "windows", "Target Microsoft Windows") orelse false;
    const target = b.resolveTargetQuery(.{
        .os_tag = if (windows) .windows else null,
    });

    //Adding Raylib-zig Dependency
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
    });
    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    const exe = b.addExecutable(.{
        .name = "app",
        .root_source_file = b.path("./src/root.zig"),
        .target = target,
    });

    //Linking C library
    exe.linkLibrary(raylib_artifact);

    //Adding Import Bindings
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
