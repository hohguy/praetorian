# Upstream plan

This fork holds changes proposed to
[victor-sys-admin/praetorian](https://github.com/victor-sys-admin/praetorian).
They go upstream in small rounds, one concern per issue and pull request,
smallest first. What's sent next depends on how the earlier rounds are
received.

## Branches

| Branch | What it is |
|---|---|
| `main` | Upstream's `main`, not kept in sync (pull request branches are cut from upstream's `main` after a fetch, not from this one). |
| `extras` | Every change below, in use on an Intel Mac (macOS 15) since 2026-11-04. This file lives here only. |
| `fix/…`, `feat/…`, `ci/…`, `test/…` | One per pull request, cut from upstream's `main`; kept after the merge. |

Each pull request branch passes `ci/check` and `ci/macos-tests` before it
is opened.

## Status

Status: `planned`, `posted` (issue or PR open), `merged`, `declined`,
`dropped`. The link is the live record; this file only points to it.
Last checked against upstream: 2026-11-22 20:51 Paris (latest release
1.5.2; 23 of our pull requests merged; issues #62 (TAP) and #63 (PIN)
open, waiting for the maintainer; no pull request open).

Pace: at most two new items a day; ready branches wait, each cut from
`main` on its own (nothing stacked). CHANGELOG: every PR adds a line to
"Unreleased", so two open PRs cut from the same `main` collide there once
one is merged, and the maintainer resolves it by hand (he did on #50,
2026-11-16). So at most one open PR of ours adds a CHANGELOG line, and a
held branch is rebased on the latest `main` right before it's posted.

### Open upstream

| Item | Change | Kind | Status |
|---|---|---|---|
| TAP | A tap formula is named two ways: `brew outdated --quiet` prints `user/tap/foo`, the build log (and so praetorian's failed-build list) uses `foo`; exact comparisons give a duplicate quarantine entry with a wrong cause, and one extra failed build (same-session skip, `filter_out`, `forget_failure` labels). Not "retried every session": corrected 2026-11-22 after review | Issue, then PR | issue posted: [#62](https://github.com/victor-sys-admin/praetorian/issues/62) 2026-11-22 (read on `main` b091947 and Homebrew source, not seen on a real tap); PR if he wants it, with SF |
| SF | Stub fidelity: `tests/stubs/brew` checked against real brew output (names, exit codes, error lines). The tap bug (TAP) passed 363 tests because the stub never prints `user/tap/name` | With TAP | planned: done as part of TAP, whose fix needs the stub to print tap names anyway; findings beyond TAP as an issue |
| PIN | praetorian has no handling of `brew pin`: `brew outdated --quiet` lists pinned formulae, so each session downloads the new version and `brew upgrade` refuses it ("Not upgrading 1 pinned package", exit 1); no build log, so never quarantined (the earlier "quarantined" here was wrong): every session ends with errors (code 2) and a failure notification. A dependent of an outdated pinned formula fails too (brew `check_install_sanity`) | Issue, then PR | issue posted: [#63](https://github.com/victor-sys-admin/praetorian/issues/63) 2026-11-22 (checked on `main` b091947 with a pinned formula on a throwaway local tap); PR if he wants it |

### Next

| Item | Change | Kind | Status |
|---|---|---|---|
| G | `--prune` offers build dependencies of formulae still in Homebrew: its candidates come from `brew leaves`, which counts runtime dependencies only (`cmd/leaves.rb`), while `brew autoremove` deliberately keeps the build dependencies of formulae built from source, "as a bottle may not be usable by the next upgrade and they take a while to install again" (`utils/autoremove.rb`). On this Mac (2026-11-22, read-only): all 20 first-round candidates are build dependencies of installed formulae (`cmake` for ~60, `meson` ~20, `rust` 7, plus `go`, `node`), 94 of 204 formulae built from source, `brew autoremove --dry-run` removes none. The README's reason for `--prune` (leftovers of migrated formulae) still holds: the check has to tell the two apart | Issue | confirmed on `main` b091947 2026-11-22; next issue once Vik has caught up |
| I2 | The report's guessed port names: obsolete ports suggested (`mysql` → `mysql81`, `mysql82`, both replaced by `mysql8`, which `--migrate` would block), and the newest versions cut from the family list (digits sorted as integers: `mysql8` before `mysql51`, `gcc44`…`gcc49` after `gcc15`, `ruby186` after `ruby40`) | PR (offered in PR #19) | two issues drafted and reviewed 2026-11-22 (obsolete candidates marked `→ replacement`; the family order hides the newest versions), files/i2-2026-11-22; post after Vik has caught up |
| TM | Tests-only PR: TA's minor gaps (empty homepage guard, the notes flag for #19/#35, #52's `--migrate` consent text, #54's fallback value) and E's unreachable dry-run guard in `macos_version_record` | PR, no CHANGELOG line | planned; mutate each guard first |
| K | The binary check (`migrate_check_binary`) covers only the ports named, not their dependencies: a dependency with no archive for this Mac is compiled during `--migrate`, without `--allow-build`, and a dry run can't show it. (The other half, "a failed binary-only install leaves its dependencies", needs `-b`, which `main` doesn't use: part of B2.) Not in the README's known limitations | Issue (or a known-limitations line) | re-checked on `main` b091947 2026-11-22 by reading; no real case found yet |

### Harm review (2026-11-22)

One read-only review of `main` a4a7e12 against a single bar: can using
praetorian as documented harm the Mac it runs on (breaks something,
removes something, tells the user something false they act on)? Not a
hunt for every defect. Each row is a hypothesis until it is re-traced
and, where possible, shown on real brew; only H1 has been. Priority and
form (issue, summary issue, README line, nothing) to decide. Not the
same as item H under Suggestions.

| Item | Harm | Status |
|---|---|---|
| H1 | `--migrate` runs `brew uninstall --formula <f>`, and `brew uninstall` autoremoves by default (`HOMEBREW_NO_AUTOREMOVE` turns it off): the formula's dependencies go in the same command, without the outside-Homebrew check (pipx, npm) that `--prune` runs on each candidate (decision 26, history row 29). Migrating a formula whose Python or node is only a dependency (pipx is the clear case) removes that Python and breaks the pipx environments, while the run says "No program outside Homebrew uses pipx" and "migrated"; its last line says the dependencies go "at the next brew autoremove", but they are already gone. The maintenance session's `brew autoremove` has the same gap for a dependency an upgrade leaves behind | confirmed 2026-11-22 on real brew (Homebrew 7.0.15, throwaway local tap: `brew uninstall --formula` removed the dependency in the same command, a script outside Homebrew that used it broke; nothing else touched); code read on `main` a4a7e12. This Mac: not exposed (no pipx, no npm global packages) |
| H2a | `--migrate` passes a formula with no commands (a library: readline, gmp, xz): nothing to compare, so the command check passes; the uninstall breaks what was built against it (a pyenv Python). `--migrate-all` takes its candidates from `brew leaves` | hypothesis (read on a4a7e12) |
| H2b | A command named with a version is "harmless" whatever the port's version: lua 5.5.1 → MacPorts lua 5.3.6 (same homepage) passes, a silent downgrade | hypothesis (read on a4a7e12; versions and homepages real on this Mac) |
| H3 | Cask reinstall (`reinstall_cask`): a stop during the backup copy or delete leaves a partial copy; a successful reinstall drops data kept in the Caskroom; unattended, a failed reinstall leaves the app removed; the `.pkg` hint suggests the forced reinstall without a copy | hypothesis (needs a half-installed cask; read on a4a7e12) |
| H4 | The shell-file check matches the literal `<prefix>/opt/<f>` only: `$(brew --prefix <f>)` and `$HOMEBREW_PREFIX/opt/<f>` lines are missed by `--migrate` and `--prune` | hypothesis (read on a4a7e12) |
| H5 | "No program outside Homebrew uses <f>" while only pipx and npm are looked at (the README states that scope): project venvs, uv tools, rbenv rubies aren't | hypothesis; wording, may fold into H1 |
| H6 | Printed hints: the undo line names a port installed before the migration; `pipx reinstall-all` touches every environment, not only the ones found | hypothesis (read on a4a7e12) |
| H7 | `--prune` doesn't run the settings search that `--migrate` and the report use | hypothesis (read on a4a7e12) |
| H8 | `sudo port uninstall inactive` also removes ports deactivated on purpose (the comment and README say "old versions") | hypothesis (MacPorts behaviour not tested) |

### Waiting

| Item | Change | Kind | Status |
|---|---|---|---|
| B1 | Maintenance upgrade one port per `port` call, without `-p`: on `main` a single `port -N -p upgrade <list>` (lib/macports.sh, checked 2026-11-15) leaves a port uninstalled when its forced rebuild fails (#74668, no `-b` needed) | Issue, then PR | planned: waits for a MacPorts release with 1d0a088 (below); F1 and F2 (sweep) first |
| B2 | `port -b` for migration installs and maintenance upgrades; `--allow-build` covers both; ports whose license allows no binary blocked | Issue, then PR | planned: waits for a MacPorts release with 1d0a088 and, for `-b -p`, macports-base #435 |

B1 and B2 wait for [MacPorts #74668](https://trac.macports.org/ticket/74668)
(`port -b -p upgrade` on a forced rebuild compiles the port, then leaves
it uninstalled). jmroot fixed it in
[1d0a088](https://github.com/macports/macports-base/commit/1d0a0882c) (master, 2026-11-20; ticket closed),
so our [PR #425](https://github.com/macports/macports-base/pull/425) was closed. With `-b -p` the port was
still built from source, then discarded: follow-up
[PR #435](https://github.com/macports/macports-base/pull/435) (2026-11-20). No release has the fix yet
(latest 2.12.7, 2026-10-13). Until one does, `extras` upgrades one port
per `port` call inside one sudo, without `-p`.

### Unattended sessions (to build on `extras` first)

Found in a real session on 2026-11-14/15 (Intel Mac, where Homebrew
builds every formula from source). `--unattended` only handles sudo.
Three other things made the session wait with nobody to answer; the
first two would stall an attended overnight session as well. Each is
built and tested on `extras` before any issue upstream; every guard
gets a test that makes it fire.

| Item | Change | Kind | Status |
|---|---|---|---|
| R2 | A step that stops making progress is never stopped: an `npm install` inside a formula build sat 7 hours on closed connections (`brew fetch --deps` doesn't fetch what a build downloads itself). A no-progress watchdog: no output and no CPU in the step's process tree for N minutes → stop the tree (escalating to SIGKILL: npm ignored SIGTERM), mark the step failed, quarantine, go on | Not now | parked: too large a change for now. If it comes back: unattended only; watch the step's process tree (new processes, CPU), not its output (brew writes build output to its own logs); fail loudly when there is no tree to watch |
| R3 | Free space is only checked between formulae (U), and the floor is 5 GB: one formula can build dozens of dependencies inside a single `brew upgrade`. Check during a step from the R2 loop; raise the floor (e.g. the larger of 20 GB and 5% of the disk) | Issue, offering a PR | floor raised to 10 GB: merged, [#51](https://github.com/victor-sys-admin/praetorian/issues/51), PR [#54](https://github.com/victor-sys-admin/praetorian/pull/54) (2026-11-20). Checking during a step: not raised, parked with R2 |
| R4 | Optional: start no new formula after a set time, so the Mac is free in the morning | Suggestion | to decide |

### Sweep of earlier work (2026-11-16)

An independent read of the `extras`-only code and of our 14 merged pull
requests together. On `main`: G1 (now merged); one `[[ … ]]` assertion without
`|| false` that can't fail (`tests/options.bats` ~368, the maintainer's
line, not ours: mention it, don't fix it in our PRs). No cross-PR
conflict, no field written and never read, CHANGELOG matches the code.

On `extras`, before B1 goes upstream:

- F1: the per-port loop runs under `sudo /bin/sh -c …`. On Ctrl-C,
  `kill_tree` (as the user) can't signal the root `sh` or `port`; sudo
  relays SIGTERM to the `sh`, which dies while the running `port upgrade`
  carries on, after praetorian said "session stopped". Trap in the loop
  script: kill the running port, then exit. (Whether sudo signals the
  whole process group isn't checked.)
- F2: each `port upgrade <p>` runs a full rev-upgrade scan; N ports, N
  scans, and a rev-upgrade failure counts as the port's. Use
  `--no-rev-upgrade` per port and one `port rev-upgrade` at the end.
- F3: a missing binary for a *dependency* gives "upgrade failed" for the
  requested port and no `--allow-build` hint (not checked against real
  MacPorts output).
- F4: a sudoers rule for `port` alone no longer covers `/bin/sh -c`; the
  refusal isn't read as a sudo failure (becomes failure + quarantine).
  Say so in the README's security section.
- F5, F6: a second "Unreleased" below 1.5.1 in `extras`' CHANGELOG
  (merge leftover, repeats a released fix); the README quotes a
  quarantine label the code doesn't write.
- F7: the loop's exit code isn't tested (the post-check hides it).
- F9, for C: a port the build bots haven't built yet also has no
  directory (404), and would get the "no archive for any version"
  message. C's wording has to allow for a new port.

Since: F9 handled in C ([#60](https://github.com/victor-sys-admin/praetorian/pull/60): "unless the port is new"); F3 overlaps K (dependencies without a binary).

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
| H | No per-port build allowance for maintenance upgrades: on `main` the MacPorts upgrade is `port -N -p upgrade <list>` with no binary check, so a port without an archive is compiled (overnight when unattended). An allowance only means something once upgrades are binary-only (B2) | Part of B2 | re-checked 2026-11-22: folded into B2, not a separate issue |

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
| Q | Any unsatisfied requirement quarantined as `xcode`; now Xcode only when Homebrew's Xcode line is there, anything else as `requirement` | merged: [#47](https://github.com/victor-sys-admin/praetorian/issues/47), PR [#48](https://github.com/victor-sys-admin/praetorian/pull/48) |
| R1 | `--unattended`: `HOMEBREW_NO_GITHUB_API=1`, so no keychain prompt after a failed build | merged: [#49](https://github.com/victor-sys-admin/praetorian/issues/49), PR [#50](https://github.com/victor-sys-admin/praetorian/pull/50) |
| F2 | CI ran the tests one at a time | merged, Linux half: [#40](https://github.com/victor-sys-admin/praetorian/issues/40), PR [#53](https://github.com/victor-sys-admin/praetorian/pull/53) (2026-11-17); the macOS runner has no GNU parallel |
| G1 | The consent prompt said "2 requests at most"; it's one request per site, following up to 5 redirects | merged: PR [#52](https://github.com/victor-sys-admin/praetorian/pull/52) (2026-11-16) |
| R3 | Free space floor 5 GB → 10 GB | merged: [#51](https://github.com/victor-sys-admin/praetorian/issues/51), PR [#54](https://github.com/victor-sys-admin/praetorian/pull/54) (2026-11-20) |
| QR | A formula that failed, then got built anyway as another formula's dependency later in the session (`llama.cpp`, via `whisper.cpp`), stays quarantined for 7 days and is listed in the failed steps. Lift the entry when the formula is installed and current at the end of the session | merged: [#58](https://github.com/victor-sys-admin/praetorian/pull/58) 2026-11-21 10:14 Paris, closing [#57](https://github.com/victor-sys-admin/praetorian/issues/57), no comments; thanked |
| TA | Tests for the guards our merged PRs left uncovered, found by an audit (2026-11-21, 60 mutations on `main` b01fc51, macOS for the tests the Linux image skips): none of our 29 added tests is redundant; uncovered: #35's `HOMEPAGE_ASK_MAX` cap (the consent text promises "the first N"), a final address answering 404/5xx taken for a match, and the reverse forwarding direction. #11's `CURL_404_RC=56` test first looked inert (no `-f` any more); the PR review showed it guards `-f` coming back (only test failing under that mutation), so it stays. Minor, left: empty homepage guard, the notes flag (#19, #35), #52's `--migrate` consent text, #54's fallback value | merged: [#59](https://github.com/victor-sys-admin/praetorian/pull/59) 2026-11-22 15:02 Paris, no comments; thanked. Tests only, no CHANGELOG line |
| C | A port with no archive at all on packages.macports.org told apart from "none for this Mac yet" | merged: [#60](https://github.com/victor-sys-admin/praetorian/pull/60) 2026-11-22 18:11 Paris, closing [#55](https://github.com/victor-sys-admin/praetorian/issues/55), no comments; thanked |
| D | `--limit N` and `--exclude a,b` for batch migrations | merged: [#61](https://github.com/victor-sys-admin/praetorian/pull/61) 2026-11-22 19:43 Paris, closing [#56](https://github.com/victor-sys-admin/praetorian/issues/56), no comments; thanked |
| E | Xcode check: re-checked on `main` b091947 (2026-11-22). The dry-run skip is documented (README `--dry-run` row: "Skips `caffeinate` and the Xcode check"), and stopping at the first problem is deliberate (comment in `check_xcode_ready`; the license and first-launch checks would run the wrong `xcodebuild` while Xcode isn't selected). Left: only a suggestion that a dry run warn, as the disk and network checks do. Side finding: `macos_version_record`'s dry-run guard is unreachable (a dry run never calls the check), so the test "dry-run: the macOS version isn't recorded" passes with the guard removed (mutation run) | not a defect (re-checked 2026-11-22): documented and deliberate; its unreachable guard goes with TM |
| J | coreutils `g`-prefixed names | dropped: Homebrew uses the same names; a `gnubin` PATH line is already blocked |
| L | Test-suite run time | folded into F |

Merged items are in 1.5.2 or earlier only where the row says so; the
rest are under "Unreleased" on `main`.
