const std = @import("std");
const output = @import("output.zig");
const cli = @import("cli.zig");

const C = output.Color;

// ── data ──────────────────────────────────────────────────────────────────────

const FakeHost = struct {
    ip: []const u8,
    mac: []const u8,
    vendor: []const u8,
    hostname: []const u8,
};

const fake_hosts = [_]FakeHost{
    .{ .ip = "192.168.1.1",  .mac = "a4:c3:f0:12:88:01", .vendor = "Netgear Inc.",         .hostname = "router.local" },
    .{ .ip = "192.168.1.5",  .mac = "b8:27:eb:44:12:fc", .vendor = "Raspberry Pi Trading", .hostname = "pi-hole.local" },
    .{ .ip = "192.168.1.12", .mac = "3c:22:fb:09:44:d1", .vendor = "Apple Inc.",            .hostname = "macbook-pro.local" },
    .{ .ip = "192.168.1.19", .mac = "dc:a6:32:77:bc:22", .vendor = "Amazon Technologies",  .hostname = "echo-dot-3.local" },
    .{ .ip = "192.168.1.23", .mac = "f0:18:98:e2:11:09", .vendor = "Samsung Electronics",  .hostname = "samsung-tv.local" },
    .{ .ip = "192.168.1.31", .mac = "00:11:32:ab:cd:ef", .vendor = "Synology Inc.",        .hostname = "nas.local" },
};

const FakePort = struct {
    port: u16,
    proto: []const u8,
    state: []const u8,
    service: []const u8,
    version: []const u8,
};

const fake_ports = [_]FakePort{
    .{ .port = 22,   .proto = "tcp", .state = "open",   .service = "ssh",       .version = "OpenSSH 9.2" },
    .{ .port = 80,   .proto = "tcp", .state = "open",   .service = "http",      .version = "nginx 1.24.0" },
    .{ .port = 443,  .proto = "tcp", .state = "open",   .service = "https",     .version = "nginx 1.24.0" },
    .{ .port = 5000, .proto = "tcp", .state = "open",   .service = "upnp",      .version = "unknown" },
    .{ .port = 8080, .proto = "tcp", .state = "closed", .service = "http-alt",  .version = "" },
    .{ .port = 9100, .proto = "tcp", .state = "open",   .service = "jetdirect", .version = "HP LaserJet" },
};

const FakeCve = struct {
    id: []const u8,
    severity: []const u8,
    description: []const u8,
    cvss: []const u8,
};

const fake_cves = [_]FakeCve{
    .{ .id = "CVE-2024-6387",  .severity = "CRITICAL", .description = "OpenSSH regreSSHion RCE (unauthenticated)", .cvss = "8.1" },
    .{ .id = "CVE-2024-1086",  .severity = "HIGH",     .description = "UPnP stack buffer overflow via SUBSCRIBE",  .cvss = "7.5" },
    .{ .id = "CVE-2023-44487", .severity = "HIGH",     .description = "HTTP/2 Rapid Reset DoS amplification",      .cvss = "7.5" },
};

// ── helpers ───────────────────────────────────────────────────────────────────

fn sleepMs(ms: u64) void {
    std.Thread.sleep(ms * std.time.ns_per_ms);
}

// In 0.15, buffering lives in the writer interface. flush() drains the buffer
// to the OS immediately — we call it after every line that should appear live.
fn printSpinner(w: *std.Io.Writer, frame: usize, label: []const u8) !void {
    const frames = [_][]const u8{ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" };
    try w.print("\r{s}{s}{s} {s}   ", .{ C.bright_cyan, frames[frame % frames.len], C.reset, label });
    try w.flush();
}

// ── scanner entry points ───────────────────────────────────────────────────────

pub fn runScan(w: *std.Io.Writer, opts: cli.ScanOptions) !void {

    try w.print("{s}initializing wraith engine...{s}\n", .{ C.dim, C.reset });
    try w.flush();
    sleepMs(400);

    try w.print("{s}loading threat signature database {s}[v2024.12.1 — 94,302 signatures]{s}\n", .{ C.dim, C.reset, C.reset });
    try w.flush();
    sleepMs(300);

    try w.print("{s}calibrating stealth probe intervals...{s}\n\n", .{ C.dim, C.reset });
    try w.flush();
    sleepMs(500);

    // ── host discovery ───────────────────────────────────────────────────────
    try w.print("{s}[ HOST DISCOVERY ]{s} target: {s}{s}{s}\n", .{ C.bright_white, C.reset, C.bright_cyan, opts.target, C.reset });
    try w.print("{s}─────────────────────────────────────────────────{s}\n", .{ C.dim, C.reset });
    try w.flush();

    var spin: usize = 0;
    for (0..18) |_| {
        try printSpinner(w, spin, "sweeping arp table...");
        spin += 1;
        sleepMs(80);
    }
    try w.print("\r{s}\r", .{" " ** 50});
    try w.flush();

    for (fake_hosts) |host| {
        try w.print("  {s}►{s} {s}{s:<17}{s} {s}{s:<20}{s} {s}{s}{s}\n", .{
            C.bright_green, C.reset,
            C.bright_white, host.ip,     C.reset,
            C.dim,          host.mac,    C.reset,
            C.cyan,         host.vendor, C.reset,
        });
        try w.flush();
        sleepMs(120);
    }

    try w.print("\n{s}  6 hosts discovered on segment{s}\n\n", .{ C.dim, C.reset });
    try w.flush();
    sleepMs(300);

    // ── port scan ────────────────────────────────────────────────────────────
    try w.print("{s}[ PORT SCAN ]{s} probing {s}192.168.1.1{s}\n", .{ C.bright_white, C.reset, C.bright_cyan, C.reset });
    try w.print("{s}─────────────────────────────────────────────────{s}\n", .{ C.dim, C.reset });
    try w.flush();

    spin = 0;
    for (0..24) |_| {
        try printSpinner(w, spin, "scanning 65535 ports...");
        spin += 1;
        sleepMs(70);
    }
    try w.print("\r{s}\r", .{" " ** 50});
    try w.flush();

    for (fake_ports) |p| {
        const state_color = if (std.mem.eql(u8, p.state, "open")) C.bright_green else C.dim;
        try w.print("  {s}{d:<7}{s} {s}{s:<8}{s} {s}{s:<12}{s} {s}{s:<16}{s} {s}{s}{s}\n", .{
            C.bright_white, p.port,    C.reset,
            C.dim,          p.proto,   C.reset,
            state_color,    p.state,   C.reset,
            C.cyan,         p.service, C.reset,
            C.dim,          p.version, C.reset,
        });
        try w.flush();
        sleepMs(90);
    }

    try w.print("\n", .{});
    try w.flush();
    sleepMs(200);

    // ── threat analysis ──────────────────────────────────────────────────────
    try w.print("{s}[ THREAT ANALYSIS ]{s} matching signatures...\n", .{ C.bright_white, C.reset });
    try w.print("{s}─────────────────────────────────────────────────{s}\n", .{ C.dim, C.reset });
    try w.flush();

    spin = 0;
    for (0..30) |_| {
        try printSpinner(w, spin, "cross-referencing CVE database...");
        spin += 1;
        sleepMs(60);
    }
    try w.print("\r{s}\r", .{" " ** 60});
    try w.flush();

    for (fake_cves) |cve| {
        const sev_color = if (std.mem.eql(u8, cve.severity, "CRITICAL")) C.bright_red else C.bright_yellow;
        try w.print("  {s}{s}{s} {s}{s:<10}{s} CVSS:{s}{s}{s}  {s}\n", .{
            sev_color, cve.id,       C.reset,
            sev_color, cve.severity, C.reset,
            C.bright_white, cve.cvss, C.reset,
            cve.description,
        });
        try w.flush();
        sleepMs(350);
    }

    try w.print("\n", .{});
    try w.flush();
    sleepMs(600);

    // ── report ───────────────────────────────────────────────────────────────
    try w.print("{s}[ GENERATING REPORT ]{s}\n", .{ C.bright_white, C.reset });
    try w.print("{s}─────────────────────────────────────────────────{s}\n", .{ C.dim, C.reset });
    try w.flush();

    spin = 0;
    for (0..20) |_| {
        try printSpinner(w, spin, "compiling findings...");
        spin += 1;
        sleepMs(80);
    }
    try w.print("\r{s}\r\n", .{" " ** 60});
    try w.flush();

    sleepMs(400);
    try w.print("{s}actually...{s}\n\n", .{ C.dim, C.reset });
    try w.flush();
    sleepMs(900);

    try aprilFoolsReveal(w);
}

pub fn runProbe(w: *std.Io.Writer, _: cli.ScanOptions) !void {

    try w.print("{s}initializing deep probe...{s}\n", .{ C.dim, C.reset });
    try w.flush();
    sleepMs(600);

    try aprilFoolsReveal(w);
}

pub fn runMonitor(w: *std.Io.Writer) !void {

    try w.print("{s}entering passive monitor mode...{s}\n", .{ C.dim, C.reset });
    try w.flush();
    sleepMs(800);

    try w.print("{s}listening on all interfaces...{s}\n\n", .{ C.dim, C.reset });
    try w.flush();
    sleepMs(1200);

    try aprilFoolsReveal(w);
}

fn aprilFoolsReveal(w: *std.Io.Writer) !void {
    sleepMs(200);

    const lines = [_][]const u8{
        "  ██╗  ██╗ █████╗ ██████╗ ██████╗ ██╗   ██╗",
        "  ██║  ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝",
        "  ███████║███████║██████╔╝██████╔╝ ╚████╔╝ ",
        "  ██╔══██║██╔══██║██╔═══╝ ██╔═══╝   ╚██╔╝  ",
        "  ██║  ██║██║  ██║██║     ██║        ██║   ",
        "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝        ╚═╝   ",
    };

    const colors = [_][]const u8{
        C.bright_red, C.bright_yellow, C.bright_green,
        C.bright_cyan, C.bright_blue, C.bright_magenta,
    };

    for (lines, 0..) |line, idx| {
        try w.print("{s}{s}{s}\n", .{ colors[idx % colors.len], line, C.reset });
        try w.flush();
        sleepMs(100);
    }

    sleepMs(300);

    const msg = "  april fool's day!";
    try w.print("\n", .{});
    try w.flush();

    for (msg) |ch| {
        const char_buf = [_]u8{ch};
        try w.print("{s}{s}{s}", .{ C.bright_yellow, &char_buf, C.reset });
        try w.flush();
        sleepMs(55);
    }

    try w.print("\n\n", .{});
    try w.flush();
    sleepMs(400);

    try w.print(
        "  {s}wraith{s} {s}is not a real tool.{s}\n" ++
        "  {s}no networks were scanned. no threats were found.{s}\n" ++
        "  {s}you just got got.{s}\n\n",
        .{
            C.bright_cyan, C.reset,
            C.dim,         C.reset,
            C.dim,         C.reset,
            C.dim,         C.reset,
        },
    );
    try w.flush();
    sleepMs(200);

    try w.print("  {s}made with zig. and love. and malice.{s}\n\n", .{ C.dim, C.reset });
    try w.flush();
}
