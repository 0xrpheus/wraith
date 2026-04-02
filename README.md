# wraith

> silent network threat detection. it sees what you don't.

[![build](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/yourhandle/wraith)
[![zig](https://img.shields.io/badge/zig-0.13.0-orange)](https://ziglang.org)
[![license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey)](https://github.com/0xrpheus/wraith/releases)

`wraith` is a zero-dependency network threat scanner written in Zig. It combines host discovery, port enumeration, and offline CVE signature matching into a single fast, static binary — no agents, no cloud, no telemetry.

Built for security engineers who want signal without noise.

---

## install

**homebrew (macOS / Linux)**
```sh
brew tap 0xrpheus/wraith
brew install wraith
```

**cargo-style one-liner (if you have zig installed)**
```sh
git clone https://github.com/0xrpheus/wraith
cd wraith
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/wraith /usr/local/bin/
```

**prebuilt binaries**

Download from [releases](https://github.com/yourhandle/wraith/releases) for:
- `wraith-macos-aarch64`
- `wraith-macos-x86_64`
- `wraith-linux-x86_64`
- `wraith-linux-aarch64`
- `wraith-windows-x86_64.exe`

---

## usage

```
wraith [command] [target] [options]

COMMANDS:
  scan    [target]   Scan a host or CIDR range for threats         (default)
  probe   [target]   Deep port probe with service fingerprinting
  monitor            Continuous passive monitoring mode
  help               Show this message
  version            Print version info

OPTIONS:
  -s, --stealth          Enable stealth mode (slower, lower detection risk)
  -V, --verbose          Verbose output
  -t, --timeout <ms>     Probe timeout in milliseconds  (default: 3000)
  -p, --ports <range>    Port range: common, all, or 80,443,8080   (default: common)
  -o, --output <file>    Write results to file
```

### examples

```sh
# scan your local subnet
wraith scan

# scan a specific range
wraith scan 10.0.0.0/24

# deep probe a host, all ports
wraith probe 192.168.1.1 --ports all --verbose

# stealth scan, extended timeout
wraith scan 192.168.1.1 --stealth --timeout 5000

# passive continuous monitoring
wraith monitor
```

---

## what it does

```
  ██╗    ██╗██████╗  █████╗ ██╗████████╗██╗  ██╗
  ██║    ██║██╔══██╗██╔══██╗██║╚══██╔══╝██║  ██║
  ██║ █╗ ██║██████╔╝███████║██║   ██║   ███████║
  ██║███╗██║██╔══██╗██╔══██║██║   ██║   ██╔══██║
  ╚███╔███╔╝██║  ██║██║  ██║██║   ██║   ██║  ██║
   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝

  v1.0.0 // silent network threat detection

initializing wraith engine...
loading threat signature database [v2024.12.1 — 94,302 signatures]
calibrating stealth probe intervals...

[ HOST DISCOVERY ] target: 192.168.1.0/24
─────────────────────────────────────────────────
  ► 192.168.1.1     a4:c3:f0:12:88:01   Netgear Inc.
  ► 192.168.1.5     b8:27:eb:44:12:fc   Raspberry Pi Trading
  ► 192.168.1.12    3c:22:fb:09:44:d1   Apple Inc.
  ...

[ PORT SCAN ] probing 192.168.1.1
─────────────────────────────────────────────────
  22      tcp    open     ssh       OpenSSH 9.2
  80      tcp    open     http      nginx 1.24.0
  443     tcp    open     https     nginx 1.24.0
  ...

[ THREAT ANALYSIS ] matching signatures...
─────────────────────────────────────────────────
  CVE-2024-6387  CRITICAL  CVSS:8.1  OpenSSH regreSSHion RCE (unauthenticated)
  CVE-2024-1086  HIGH      CVSS:7.5  UPnP stack buffer overflow via SUBSCRIBE
  ...
```

---

## how it works

wraith operates in three phases:

**1. host discovery**
ARP sweep across the target segment. No ICMP, no noise. Identifies live hosts with MAC/vendor resolution against a bundled OUI database.

**2. port enumeration**
TCP SYN scanning against configurable port ranges. Stealth mode adds randomized inter-probe delays and jittered TTLs to evade basic IDS signatures.

**3. threat matching**
Detected services are matched offline against a bundled CVE signature database, cross-referenced by service name, version, and protocol fingerprint. No data leaves your machine.

---

## why zig?

wraith is written in [Zig](https://ziglang.org) for a few concrete reasons:

- **single static binary** — no runtime, no dynamic linking, no `libssl` version hell
- **cross-compilation** — one build machine can target all platforms
- **deterministic builds** — same source, same binary, every time
- **no allocator surprises** — explicit memory management means predictable behavior under load
- **comptime CVE embedding** — the signature database is embedded at compile time via `@embedFile`, making the binary fully self-contained

---

## building from source

requires zig `0.14.0+`

```sh
# debug build
zig build

# release build (recommended)
zig build -Doptimize=ReleaseFast

# cross-compile for linux from macos
zig build -Dtarget=x86_64-linux -Doptimize=ReleaseFast
```

---

## man page

```sh
man wraith
```

Installed automatically via homebrew. For manual installs:

```sh
sudo cp man/wraith.1 /usr/local/share/man/man1/
sudo mandb  # linux
```

---

## roadmap

- [ ] JSON/structured output mode
- [ ] SARIF output for CI integration
- [ ] IPv6 support
- [ ] configurable OUI database updates
- [ ] TUI dashboard mode

---

## license

MIT. see [LICENSE](LICENSE).

---

## contributing

PRs welcome. Open an issue first for anything substantial. Code style follows `zig fmt`.
