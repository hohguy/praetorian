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
| `fix/…`, `feat/…`, `ci/…` | One per pull request, cut from `main`. |

Each pull request branch passes `ci/check` and `ci/macos-tests` before it
is opened.

## Rounds

Status: `planned`, `posted` (issue or PR open), `merged`, `declined`,
`dropped`. The link is the live record; this table only points to it.

### Round 1: small bug fixes

| Item | Change | Kind | Status |
|---|---|---|---|
| A | Binary check reads the HTTP status: macOS's own curl (8.7.1) exits 56, not 22, for a 404 over HTTP/2 | Issue + PR | merged, released in 1.5.1: [#8](https://github.com/victor-sys-admin/praetorian/issues/8), PR [#11](https://github.com/victor-sys-admin/praetorian/pull/11) |
| M | `--doctor` says a formula "isn't installed" when only its `opt` link is missing | Issue, then PR (asked for) | merged, released in 1.5.2: [#9](https://github.com/victor-sys-admin/praetorian/issues/9), PR [#13](https://github.com/victor-sys-admin/praetorian/pull/13) |
| N | `--doctor` misses a root-only symlink in the Homebrew prefix that makes `brew cleanup` fail | Issue, then PR (asked for) | merged, released in 1.5.2: [#10](https://github.com/victor-sys-admin/praetorian/issues/10), PR [#14](https://github.com/victor-sys-admin/praetorian/pull/14) |

### Round 2: test speed

| Item | Change | Kind | Status |
|---|---|---|---|
| F | `ci/macos-tests --jobs N` with GNU parallel, for contributors (the app itself doesn't use it) | Issue + PR | merged: [#16](https://github.com/victor-sys-admin/praetorian/issues/16), PR [#17](https://github.com/victor-sys-admin/praetorian/pull/17) |

### Round 3: migration correctness

| Item | Change | Kind | Status |
|---|---|---|---|
| I | An obsolete MacPorts port (`replaced_by`, e.g. `docbook-xsl` → `docbook-xsl-nons`) is taken as is: "no binary" block, listed under "Same name" | Issue + PR | merged: [#18](https://github.com/victor-sys-admin/praetorian/issues/18), PR [#19](https://github.com/victor-sys-admin/praetorian/pull/19) |
| T | Settings outside the shell startup files (Git credential helper, app settings, launch daemons) can name the formula's Homebrew path; proposed: a filtered read-only search in `--migration-report` and `--doctor` | Issue (PR offered) | posted: [#20](https://github.com/victor-sys-admin/praetorian/issues/20); built and merged by the maintainer in PR [#22](https://github.com/victor-sys-admin/praetorian/pull/22) (2026-11-11), tested on a real Mac: works, two findings filed as X |

### Round 4

| Item | Change | Kind | Status |
|---|---|---|---|
| E | Xcode: a dry run warns instead of skipping the check; every problem listed at once | Issue, then PR if wanted | planned |
| D | `--limit N` and `--exclude a,b` for batch migrations | Issue, then PR if wanted | planned |

### Round 5: binary-only MacPorts

| Item | Change | Kind | Status |
|---|---|---|---|
| B | `port -b` for migration installs and maintenance upgrades; `--allow-build` covers both; ports whose license allows no binary blocked | Issue, then PR | planned |
| C | A port with no archive at all on packages.macports.org told apart from "none for this Mac yet" | Issue, then PR | planned |

B waits for [MacPorts #74668](https://trac.macports.org/ticket/74668)
(`port -b -p upgrade` on a forced rebuild compiles the port, then leaves
it uninstalled). Until a fixed MacPorts is released, `extras` upgrades
one port per `port` call inside one sudo, without `-p`.

### Later, depending on the response

| Item | Change | Kind | Status |
|---|---|---|---|
| G | Build dependencies of formulae still in Homebrew aren't taken into account (`--prune` offers the compilers Homebrew needs to build what stays) | Issue | planned |
| H | No per-port build allowance for maintenance upgrades | Issue | planned |
| J | coreutils: MacPorts installs `g`-prefixed names; not in the known-traps table | Issue | dropped: Homebrew's coreutils uses the same `g` names and `libexec/gnubin`; a `gnubin` PATH line is already blocked |
| K | A dry run can't predict a dependency with no binary; a failed binary-only install leaves the dependencies it already installed | Issue | planned |
| L | Test-suite run time | Issue | folded into F (timings in #16 and #17) |
| O | A block message gives a machine-specific example ("every mysql port on this Mac") | Issue + PR | ready on `fix/no-binary-example` (2 commits on ddfca70, not pushed); next round |
| P | The progress line isn't cleared before the ✓; MacPorts' "ports you installed have notes" isn't shown | Issue | checked on ddfca70: the notes part still applies (nothing reads "ports you installed have notes"); the progress part is likely the line wrapping past 80 columns, as `\r\033[K` clears one screen line: reproduce before filing |
| S | The report flags the same project under an old and a new homepage address | Issue (maybe PR) | still applies on ddfca70 (`git-lfs.com` vs `git-lfs.github.com`), and also `gi.readthedocs.io/en/latest/` vs `gi.readthedocs.io`; following redirects (`curl -sIL`, final URL) resolves both |
| U | Disk use during a long formula upgrade: free space is checked only at the start and `brew cleanup` runs only at the end (suggest `brew cleanup <formula>` after each upgrade, a free-space check before each formula, and on low space: stop, skip the casks, still clean up) | Issue (feature request) | done by the maintainer: [#24](https://github.com/victor-sys-admin/praetorian/issues/24), his PR [#27](https://github.com/victor-sys-admin/praetorian/pull/27), merged 2026-11-11 |
| V | CONTRIBUTING step 4 says to add the CHANGELOG line to "the top entry (the version being prepared)", but each release removes `## Unreleased` and the maintainer recreates it by hand (#14, #17) | Issue (question) | done by the maintainer on main (CONTRIBUTING step 4 now says "Unreleased", created when missing) |
| W | `ci/macos-tests tests/<file>.bats` runs the file twice (the script always adds `tests`), and the copies collide ("File exists", "setup_file failed"); fix: add `tests` only when no file or folder is given | Issue + PR | merged: [#25](https://github.com/victor-sys-admin/praetorian/issues/25), PR [#26](https://github.com/victor-sys-admin/praetorian/pull/26) |
| I2 | The report doesn't check guessed port names (`node` → `nodejs22`) for `replaced_by`; `--migrate` does | Offered in PR #19 (merged without a reply to the offer) | planned |

Items G to L are features that may not fit a project that is "small on
purpose". They are written up as suggestions, not requests.

### After testing #22 on a real Mac

| Item | Change | Kind | Status |
|---|---|---|---|
| X | Settings search: a path in a binary plist glued to the next string (cut at non-printable bytes, but a short string's marker byte is printable); the MacPorts installer's `.macports-saved_…` copies read | Issue + PR | posted: [#28](https://github.com/victor-sys-admin/praetorian/issues/28), PR [#29](https://github.com/victor-sys-admin/praetorian/pull/29) |
