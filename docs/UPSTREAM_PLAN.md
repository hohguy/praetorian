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
Last checked against upstream: 2026-11-15 (latest release 1.5.2; 14 of
our pull requests merged; issue #40 open).

### Open upstream

| Item | Change | Kind | Status |
|---|---|---|---|
| F2 | CI runs the tests one at a time; `--jobs` in CI (the bats container has GNU parallel, the macOS runner doesn't) | Issue (his decision) | posted: [#40](https://github.com/victor-sys-admin/praetorian/issues/40), no reply yet. His CI rework ([#41](https://github.com/victor-sys-admin/praetorian/pull/41), [#42](https://github.com/victor-sys-admin/praetorian/pull/42)) runs the jobs in parallel, not the tests. Mostly a gain for contributors waiting on CI. Its prerequisite, Y, is merged. |

### Next

| Item | Change | Kind | Status |
|---|---|---|---|
| Q | Any "An unsatisfied requirement failed this build" is quarantined as `xcode` (`lib/session.sh` on `main`, checked 2026-11-15): the summary says to install Xcode for a formula that needs an `arm64` Mac (`openjdk` 27 and what depends on it, on an Intel Mac), and on a Mac with Xcode the entry is lifted and the formula retried every session. Xcode only when Homebrew's Xcode line is there; anything else as `requirement`, 30 days | Issue + PR | on `extras` (2026-11-15, 378 tests pass); upstream next |
| C | A port with no archive at all on packages.macports.org told apart from "none for this Mac yet" (both read "has no archive of … for <platform>" on `main`, checked 2026-11-14) | Issue, then PR | planned: doesn't depend on MacPorts #74668, so it can go before B. With it: a port with no binary yet isn't a failure and shouldn't suggest `port clean` or Trac (seen 2026-11-15: `gh`, `p5.34-json-xs`) |
| I2 | The report doesn't check guessed port names (`node` → `nodejs22`) for `replaced_by`; `--migrate` does | PR (offered in PR #19) | planned: moved up; the offer in #19 probably went unnoticed, so we send it. Not rechecked on `main` yet. |
| E | Xcode: a dry run skips the check instead of warning (`praetorian`: `[[ "${DRY_RUN}" == true ]] \|\| check_xcode_ready`), and the check stops at the first problem (checked on `main` 2026-11-14) | Issue, then PR if wanted | planned |
| D | `--limit N` and `--exclude a,b` for batch migrations (not on `main`, checked 2026-11-14) | Issue, then PR if wanted | planned |

### Waiting

| Item | Change | Kind | Status |
|---|---|---|---|
| B1 | Maintenance upgrade one port per `port` call, without `-p`: on `main` a single `port -N -p upgrade <list>` (lib/macports.sh, checked 2026-11-15) leaves a port uninstalled when its forced rebuild fails (#74668, no `-b` needed) | Issue, then PR | planned: waits for macports-base PR #425 to be merged or released (below) |
| B2 | `port -b` for migration installs and maintenance upgrades; `--allow-build` covers both; ports whose license allows no binary blocked | Issue, then PR | planned: waits for the same, ideally a MacPorts release with the fix |

B1 and B2 wait for [MacPorts #74668](https://trac.macports.org/ticket/74668)
(`port -b -p upgrade` on a forced rebuild compiles the port, then leaves
it uninstalled). A fix is proposed in
[macports-base PR #425](https://github.com/macports/macports-base/pull/425)
(2026-11-13; CI green on macOS 15 and 26, no review yet as of 2026-11-15). Until a
MacPorts release includes a fix, `extras` upgrades one port per `port`
call inside one sudo, without `-p`.

### Unattended sessions (to build on `extras` first)

Found in a real session on 2026-11-14/15 (Intel Mac, where Homebrew
builds every formula from source). `--unattended` only handles sudo.
Three other things made the session wait with nobody to answer; the
first two would stall an attended overnight session as well. Each is
built and tested on `extras` before any issue upstream; every guard
gets a test that makes it fire.

| Item | Change | Kind | Status |
|---|---|---|---|
| R1 | After a failed build, Homebrew looks up a GitHub token to search for known issues, and asks the macOS keychain; the session waited on that prompt. `--unattended` ("never waits for input") now sets `HOMEBREW_NO_GITHUB_API=1`; attended sessions are left alone | `extras`, then issue + PR | on `extras` (2026-11-15). Checked inside Homebrew 7.0.13: one issue search calls the keychain lookup twice without it, never with it |
| R2 | A step that stops making progress is never stopped: an `npm install` inside a formula build sat 7 hours on closed connections (`brew fetch --deps` doesn't fetch what a build downloads itself). A no-progress watchdog: no output and no CPU in the step's process tree for N minutes → stop the tree (escalating to SIGKILL: npm ignored SIGTERM), mark the step failed, quarantine, go on | Not now | parked: too large a change for now. If it comes back: unattended only; watch the step's process tree (new processes, CPU), not its output (brew writes build output to its own logs); fail loudly when there is no tree to watch |
| R3 | Free space is only checked between formulae (U), and the floor is 5 GB: one formula can build dozens of dependencies inside a single `brew upgrade`. Check during a step from the R2 loop; raise the floor (e.g. the larger of 20 GB and 5% of the disk) | Issue, offering a PR | planned: ask plainly whether to raise the 5 GB floor (10 GB, or more), and whether to check during a step; mention that B1 (one port per `port` call) already limits a single step on the MacPorts side |
| R4 | Optional: start no new formula after a set time, so the Mac is free in the morning | Suggestion | to decide |

### Candidates (seen 2026-11-15, not checked on `main` yet)

| Item | Change | Kind | Status |
|---|---|---|---|
| QR | A formula that failed, then got built anyway as another formula's dependency later in the session (`llama.cpp`, via `whisper.cpp`), stays quarantined for 7 days and is reported as a failed build. Lift the entry when the formula is installed and current at the end of the session | Issue, then PR | to check on `main` |
| PIN | praetorian has no handling of `brew pin`: if `brew outdated` still lists pinned formulae, they are tried, fail and get quarantined | Issue if confirmed | to check (with a throwaway formula, not the Mac's own) |

### Outside praetorian

- Homebrew 7.0.13 (`utils/github/api.rb`): a failed GitHub token lookup
  isn't cached (`@credentials ||=` keeps nothing for no token, and
  `credentials_type` calls `keychain_username_password` directly), and
  the keychain lookup has no timeout. When the keychain helper waits, every
  GitHub call after a failed build waits again. To reproduce on its own
  before any report (Intel macOS is Homebrew's Tier 3). Harder on the
  development Mac now: the keychain item was set to "Always Allow" on
  2026-11-15.
- Not a bug: `openjdk` 27 declares `depends_on arch: :arm64` on macOS
  (its only macOS boot JDK is `aarch64`), so Homebrew no longer builds
  Java on Intel Macs. What Q fixes is praetorian's advice about it.

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
| Y | Two tests assumed a session under a minute and failed under load | merged: [#45](https://github.com/victor-sys-admin/praetorian/issues/45), PR [#46](https://github.com/victor-sys-admin/praetorian/pull/46) (2026-11-15) |
| J | coreutils `g`-prefixed names | dropped: Homebrew uses the same names; a `gnubin` PATH line is already blocked |
| L | Test-suite run time | folded into F |

Merged items are in 1.5.2 or earlier only where the row says so; the
rest are under "Unreleased" on `main`.
