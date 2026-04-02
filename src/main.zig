const std = @import("std");
const cli = @import("cli.zig");
const output = @import("output.zig");
const scanner = @import("scanner.zig");
const version = @import("version.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stdout_buf: [4096]u8 = undefined;
    var stdout_raw = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_raw.interface;

    var stderr_raw = std.fs.File.stderr().writer(&.{});
    const stderr = &stderr_raw.interface;

    const parsed = cli.parse(allocator) catch |err| {
        try stderr.print("wraith: argument error: {}\n", .{err});
        std.process.exit(1);
    };
    // parsed._args holds the raw argv allocation. scan_opts may contain slices
    // pointing into it, so we must not free until after the switch completes.
    defer std.process.argsFree(allocator, parsed._args);

    switch (parsed.command) {
        .help => {
            try output.printBanner(stdout);
            try cli.printHelp(stdout);
            try stdout.flush();
        },
        .ver => {
            try stdout.print("wraith {s} (built {s})\n", .{ version.VERSION, version.BUILD_DATE });
            try stdout.print("{s}\n", .{version.DESCRIPTION});
            try stdout.flush();
        },
        .scan => {
            try output.printBanner(stdout);
            try stdout.flush();
            scanner.runScan(stdout, parsed.scan_opts) catch |err| {
                try stderr.print("wraith: scan failed: {}\n", .{err});
                std.process.exit(1);
            };
        },
        .probe => {
            try output.printBanner(stdout);
            try stdout.flush();
            scanner.runProbe(stdout, parsed.scan_opts) catch |err| {
                try stderr.print("wraith: probe failed: {}\n", .{err});
                std.process.exit(1);
            };
        },
        .monitor => {
            try output.printBanner(stdout);
            try stdout.flush();
            scanner.runMonitor(stdout) catch |err| {
                try stderr.print("wraith: monitor failed: {}\n", .{err});
                std.process.exit(1);
            };
        },
    }
}
