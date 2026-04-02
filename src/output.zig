const std = @import("std");

pub const Color = struct {
    pub const reset         = "\x1b[0m";
    pub const bold          = "\x1b[1m";
    pub const dim           = "\x1b[2m";

    pub const red           = "\x1b[31m";
    pub const green         = "\x1b[32m";
    pub const yellow        = "\x1b[33m";
    pub const blue          = "\x1b[34m";
    pub const magenta       = "\x1b[35m";
    pub const cyan          = "\x1b[36m";
    pub const white         = "\x1b[37m";

    pub const bright_red    = "\x1b[91m";
    pub const bright_green  = "\x1b[92m";
    pub const bright_yellow = "\x1b[93m";
    pub const bright_blue   = "\x1b[94m";
    pub const bright_magenta= "\x1b[95m";
    pub const bright_cyan   = "\x1b[96m";
    pub const bright_white  = "\x1b[97m";
};

pub fn printBanner(w: *std.Io.Writer) !void {
    try w.print(
        \\{s}{s}
        \\  ██╗    ██╗██████╗  █████╗ ██╗████████╗██╗  ██╗
        \\  ██║    ██║██╔══██╗██╔══██╗██║╚══██╔══╝██║  ██║
        \\  ██║ █╗ ██║██████╔╝███████║██║   ██║   ███████║
        \\  ██║███╗██║██╔══██╗██╔══██║██║   ██║   ██╔══██║
        \\  ╚███╔███╔╝██║  ██║██║  ██║██║   ██║   ██║  ██║
        \\   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝
        \\{s}
        \\  {s}v1.0.0{s} {s}// silent network threat detection{s}
        \\
        \\
    , .{
        Color.bright_cyan, Color.bold,
        Color.reset,
        Color.bright_blue, Color.reset,
        Color.dim,         Color.reset,
    });
}

pub fn printInfo(w: *std.Io.Writer, comptime fmt: []const u8, args: anytype) !void {
    try w.print("{s}[{s}*{s}]{s} " ++ fmt ++ "\n", .{ Color.dim, Color.bright_cyan, Color.dim, Color.reset } ++ args);
}

pub fn printWarn(w: *std.Io.Writer, comptime fmt: []const u8, args: anytype) !void {
    try w.print("{s}[{s}!{s}]{s} " ++ fmt ++ "\n", .{ Color.dim, Color.yellow, Color.dim, Color.reset } ++ args);
}

pub fn printThreat(w: *std.Io.Writer, comptime fmt: []const u8, args: anytype) !void {
    try w.print("{s}[{s}THREAT{s}]{s} " ++ fmt ++ "\n", .{ Color.dim, Color.bright_red, Color.dim, Color.reset } ++ args);
}

pub fn printSuccess(w: *std.Io.Writer, comptime fmt: []const u8, args: anytype) !void {
    try w.print("{s}[{s}+{s}]{s} " ++ fmt ++ "\n", .{ Color.dim, Color.bright_green, Color.dim, Color.reset } ++ args);
}
