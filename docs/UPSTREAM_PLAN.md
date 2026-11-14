# Upstream plan

This fork holds changes proposed to
[victor-sys-admin/praetorian](https://github.com/victor-sys-admin/praetorian).
They go upstream in small rounds, one concern per issue and pull request,
smallest first. What's sent next depends on how the earlier rounds are
received.

## Branches

| Branch | What it is |
|---|---|
| `main` | Upstream's `main`, unchanged. Pull request branches start from it. |
| `extras` | Every change below, in use on an Intel Mac (macOS 15) since 2026-11-04. This file lives here only. |
| `fix/…`, `feat/…`, `ci/…` | One per pull request, cut from `main`, deleted once merged. |

Each pull request branch passes `ci/check` and `ci/macos-tests` before it
is opened.

## Status

Status: `planned`, `posted` (issue or PR open), `merged`, `declined`,
`dropped`. The link is the live record; this file only points to it.
Last checked against upstream: 2026-11-14 (latest release 1.5.2; 13 of
our pull requests merged, issue #40 open).

### Open upstream

| Item | Change | Kind | Status |
|---|---|---|---|
| F2 | CI runs the tests one at a time; `--jobs` in CI (the bats container has GNU parallel, the macOS runner doesn't) | Issue (his decision) | posted: [#40](https://github.com/victor-sys-admin/praetorian/issues/40), no reply yet. His CI rework ([#41](https://github.com/victor-sys-admin/praetorian/pull/41), [#42](https://github.com/victor-sys-admin/praetorian/pull/42)) runs the jobs in parallel, not the tests. Mostly a gain for contributors waiting on CI. |

### Next

| Item | Change | Kind | Status |
|---|---|---|---|
| Y | Two tests assume a session under a minute and fail under load: "notify: unattended success" (gets "Done in 1 min") and "lock whose PID was reused by another program" (`sleep 60` ends first, `kill` fails); failures recorded on 2026-11-11 | Issue + PR | planned: a test bug in its own right, also a prerequisite for F2 |
| C | A port with no archive at all on packages.macports.org told apart from "none for this Mac yet" (both read "has no archive of … for <platform>" on `main`, checked 2026-11-14) | Issue, then PR | planned: doesn't depend on MacPorts #74668, so it can go before B |
| E | Xcode: a dry run skips the check instead of warning (`praetorian`: `[[ "${DRY_RUN}" == true ]] \|\| check_xcode_ready`), and the check stops at the first problem (checked on `main` 2026-11-14) | Issue, then PR if wanted | planned |
| D | `--limit N` and `--exclude a,b` for batch migrations (not on `main`, checked 2026-11-14) | Issue, then PR if wanted | planned |

### Waiting

| Item | Change | Kind | Status |
|---|---|---|---|
| I2 | The report doesn't check guessed port names (`node` → `nodejs22`) for `replaced_by`; `--migrate` does | Offered in PR #19 | planned: merged without a reply to the offer; not rechecked on `main` |
| B | `port -b` for migration installs and maintenance upgrades; `--allow-build` covers both; ports whose license allows no binary blocked | Issue, then PR | planned: waits for a MacPorts release with a fix for #74668 (below) |

B waits for [MacPorts #74668](https://trac.macports.org/ticket/74668)
(`port -b -p upgrade` on a forced rebuild compiles the port, then leaves
it uninstalled). A fix is proposed in
[macports-base PR #425](https://github.com/macports/macports-base/pull/425)
(2026-11-13; CI green on macOS 15 and 26, no review yet). Until a
MacPorts release includes a fix, `extras` upgrades one port per `port`
call inside one sudo, without `-p`.

### Suggestions (features)

Features that may not fit a project that is "small on purpose". They are
written up as suggestions, not requests. With the bug fixes mostly
merged, some may move up.

| Item | Change | Kind | Status |
|---|---|---|---|
| G | Build dependencies of formulae still in Homebrew aren't taken into account (`--prune` offers the compilers Homebrew needs to build what stays) | Issue | planned |
| H | No per-port build allowance for maintenance upgrades | Issue | planned |
| K | A dry run can't predict a dependency with no binary; a failed binary-only install leaves the dependencies it already installed | Issue | planned |

### Done

| Item | Change | Status |
|---|---|---|
| A | Binary check reads the HTTP status: macOS's own curl (8.7.1) exits 56, not 22, for a 404 over HTTP/2 | merged, released in 1.5.1: [#8](https://github.com/victor-sys-admin/praetorian/issues/8), PR [#11](https://github.com/victor-sys-admin/praetorian/pull/11) |
| M | `--doctor` says a formula "isn't installed" when only its `opt` link is missing | merged, released in 1.5.2: [#9](https://github.com/victor-sys-admin/praetorian/issues/9), PR [#13](https://github.com/victor-sys-admin/praetorian/pull/13) |
| N | `--doctor` misses a root-only symlink in the Homebrew prefix that makes `brew cleanup` fail | merged, released in 1.5.2: [#10](https://github.com/victor-sys-admin/praetorian/issues/10), PR [#14](https://github.com/victor-sys-admin/praetorian/pull/14) |
| F | `ci/macos-tests --jobs N` with GNU parallel, for contributors | merged: [#16](https://github.com/victor-sys-admin/praetorian/issues/16), PR [#17](https://github.com/victor-sys-admin/praetorian/pull/17) |
| I | An obsolete MacPorts port (`replaced_by`) is taken as is | merged: [#18](https://github.com/victor-sys-admin/praetorian/issues/18), PR [#19](https://github.com/victor-sys-admin/praetorian/pull/19) |
| T | Settings outside the shell startup files can name the formula's Homebrew path | built and merged by the maintainer: [#20](https://github.com/victor-sys-admin/praetorian/issues/20), his PR [#22](https://github.com/victor-sys-admin/praetorian/pull/22) |
| U | Disk use during a long formula upgrade | built and merged by the maintainer: [#24](https://github.com/victor-sys-admin/praetorian/issues/24), his PR [#27](https://github.com/victor-sys-admin/praetorian/pull/27) |
| V | CONTRIBUTING step 4 and the "Unreleased" section | done by the maintainer on `main` |
| W | `ci/macos-tests tests/<file>.bats` runs the file twice | merged: [#25](https://github.com/victor-sys-admin/praetorian/issues/25), PR [#26](https://github.com/victor-sys-admin/praetorian/pull/26) |
| X | Settings search: binary plists, MacPorts installer backups | merged: [#28](https://github.com/victor-sys-admin/praetorian/issues/28), PR [#29](https://github.com/victor-sys-admin/praetorian/pull/29) |
| O | A block message gives a machine-specific example | merged: [#30](https://github.com/victor-sys-admin/praetorian/issues/30), PR [#31](https://github.com/victor-sys-admin/praetorian/pull/31) |
| S1 | One project flagged as two: a Read the Docs version path, the old GitHub Pages form | merged: [#32](https://github.com/victor-sys-admin/praetorian/issues/32), PR [#33](https://github.com/victor-sys-admin/praetorian/pull/33) (2026-11-12) |
| S2 | The same for a project that moved to another domain (ask the project sites, with consent) | merged: [#34](https://github.com/victor-sys-admin/praetorian/issues/34), PR [#35](https://github.com/victor-sys-admin/praetorian/pull/35) (2026-11-14) |
| P1 | MacPorts' "ports you installed have notes" only reached the log | merged: [#36](https://github.com/victor-sys-admin/praetorian/issues/36), PR [#37](https://github.com/victor-sys-admin/praetorian/pull/37) (2026-11-14) |
| Z | Every step lasted at least 2 seconds | merged: [#38](https://github.com/victor-sys-admin/praetorian/issues/38), PR [#39](https://github.com/victor-sys-admin/praetorian/pull/39) (2026-11-14) |
| P2 | A progress line wider than the terminal left lines behind | merged: [#43](https://github.com/victor-sys-admin/praetorian/issues/43), PR [#44](https://github.com/victor-sys-admin/praetorian/pull/44) (2026-11-14) |
| J | coreutils `g`-prefixed names | dropped: Homebrew uses the same names; a `gnubin` PATH line is already blocked |
| L | Test-suite run time | folded into F |

Merged items are in 1.5.2 or earlier only where the row says so; the
rest are under "Unreleased" on `main`.
