const std = @import("std");
const version = @import("version.zig");
const output = @import("output.zig");

pub const Command = enum {
    scan,
    probe,
    monitor,
    help,
    ver,
};

pub const ScanOptions = struct {
    target: []const u8 = "192.168.1.0/24",
    timeout: u32 = 3000,
    ports: []const u8 = "common",
    stealth: bool = false,
    verbose: bool = false,
    output_file: ?[]const u8 = null,
};

pub const ParsedArgs = struct {
    command: Command,
    scan_opts: ScanOptions,
    // The raw args allocation. Caller must free with std.process.argsFree()
    // after it is done using any slices inside scan_opts, since those slices
    // point directly into this buffer.
    _args: [][:0]u8,
};

pub fn parse(allocator: std.mem.Allocator) !ParsedArgs {
    // NOTE: we do NOT defer argsFree here. scan_opts may hold slices
    // (target, ports, output_file) that point directly into this buffer.
    // The caller owns _args and must free it after use.
    const args = try std.process.argsAlloc(allocator);

    if (args.len < 2) {
        return ParsedArgs{ .command = .scan, .scan_opts = .{}, ._args = args };
    }

    const cmd_str = args[1];

    if (std.mem.eql(u8, cmd_str, "help") or
        std.mem.eql(u8, cmd_str, "--help") or
        std.mem.eql(u8, cmd_str, "-h"))
    {
        return ParsedArgs{ .command = .help, .scan_opts = .{}, ._args = args };
    }

    if (std.mem.eql(u8, cmd_str, "version") or
        std.mem.eql(u8, cmd_str, "--version") or
        std.mem.eql(u8, cmd_str, "-v"))
    {
        return ParsedArgs{ .command = .ver, .scan_opts = .{}, ._args = args };
    }

    if (std.mem.eql(u8, cmd_str, "probe")) {
        return ParsedArgs{ .command = .probe, .scan_opts = .{}, ._args = args };
    }

    if (std.mem.eql(u8, cmd_str, "monitor")) {
        return ParsedArgs{ .command = .monitor, .scan_opts = .{}, ._args = args };
    }

    var opts = ScanOptions{};

    if (!std.mem.startsWith(u8, args[1], "-")) {
        opts.target = args[1];
    }

    var i: usize = 2;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (std.mem.eql(u8, arg, "--stealth") or std.mem.eql(u8, arg, "-s")) {
            opts.stealth = true;
        } else if (std.mem.eql(u8, arg, "--verbose") or std.mem.eql(u8, arg, "-V")) {
            opts.verbose = true;
        } else if (std.mem.eql(u8, arg, "--timeout") or std.mem.eql(u8, arg, "-t")) {
            i += 1;
            if (i < args.len) {
                opts.timeout = std.fmt.parseInt(u32, args[i], 10) catch 3000;
            }
        } else if (std.mem.eql(u8, arg, "--ports") or std.mem.eql(u8, arg, "-p")) {
            i += 1;
            if (i < args.len) {
                opts.ports = args[i];
            }
        } else if (std.mem.eql(u8, arg, "--output") or std.mem.eql(u8, arg, "-o")) {
            i += 1;
            if (i < args.len) {
                opts.output_file = args[i];
            }
        }
    }

    return ParsedArgs{ .command = .scan, .scan_opts = opts, ._args = args };
}

pub fn printHelp(w: *std.Io.Writer) !void {
    try w.print(
        \\{s}USAGE:{s}
        \\  wraith [command] [target] [options]
        \\
        \\{s}COMMANDS:{s}
        \\  scan    [target]   Scan a host or CIDR range for threats         {s}(default){s}
        \\  probe   [target]   Deep port probe with service fingerprinting
        \\  monitor            Continuous passive monitoring mode
        \\  help               Show this message
        \\  version            Print version info
        \\
        \\{s}OPTIONS:{s}
        \\  -s, --stealth          Enable stealth mode (slower, lower detection risk)
        \\  -V, --verbose          Verbose output
        \\  -t, --timeout <ms>     Probe timeout in milliseconds  {s}(default: 3000){s}
        \\  -p, --ports <range>    Port range: common, all, or 80,443,8080   {s}(default: common){s}
        \\  -o, --output <file>    Write results to file
        \\
        \\{s}EXAMPLES:{s}
        \\  wraith scan 192.168.1.0/24
        \\  wraith probe 10.0.0.1 --ports all --verbose
        \\  wraith scan 192.168.1.1 --stealth --timeout 5000
        \\  wraith monitor
        \\
        \\{s}DOCS:{s}
        \\  man wraith
        \\  https://github.com/yourhandle/wraith
        \\
    , .{
        output.Color.bright_white, output.Color.reset,
        output.Color.bright_white, output.Color.reset,
        output.Color.dim,          output.Color.reset,
        output.Color.bright_white, output.Color.reset,
        output.Color.dim,          output.Color.reset,
        output.Color.dim,          output.Color.reset,
        output.Color.bright_white, output.Color.reset,
        output.Color.bright_white, output.Color.reset,
    });
}
