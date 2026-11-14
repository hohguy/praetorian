#!/usr/bin/env bats
#
# Documentation and version tests: verifies that README.md, CHANGELOG.md,
# and --help outputs match PRAETORIAN_VERSION and usage documentation.
#
# shellcheck disable=SC2030,SC2031

setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    mkdir -p "${HOME}"
    export PATH="${BATS_TEST_DIRNAME}/stubs:${PATH}"
    PRAETORIAN="${BATS_TEST_DIRNAME}/../praetorian"
    SCHEDULE="${BATS_TEST_DIRNAME}/../praetorian-schedule"
    SUDO_SETUP="${BATS_TEST_DIRNAME}/../praetorian-sudo-setup"
}

@test "version: README's latest release and CHANGELOG's first numbered entry match PRAETORIAN_VERSION" {
    local root="${BATS_TEST_DIRNAME}/.." version readme changelog
    version=$(sed -nE 's/^readonly PRAETORIAN_VERSION="([^"]*)"$/\1/p' "${root}/praetorian")
    readme=$(sed -n '/^## Latest release/,/^## /p' "${root}/README.md" | sed -nE 's/^### ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)
    changelog=$(sed -nE 's/^## ([0-9]+\.[0-9]+\.[0-9]+) .*/\1/p' "${root}/CHANGELOG.md" | head -n 1)
    [ -n "${version}" ]
    [ "${readme}" = "${version}" ]
    [ "${changelog}" = "${version}" ]
}

@test "version: --help shows PRAETORIAN_VERSION, a X.Y.Z version" {
    local version
    version=$(sed -nE 's/^readonly PRAETORIAN_VERSION="([^"]*)"$/\1/p' "${BATS_TEST_DIRNAME}/../praetorian")
    [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || false
    run "${PRAETORIAN}" --help
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"praetorian ${version} "* ]] || false
}

@test "praetorian: --help prints the usage" {
    run "${PRAETORIAN}" --help
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"Usage: praetorian"* ]] || false
}

@test "schedule: --help prints the usage" {
    run "${SCHEDULE}" --help
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"install [--at HH:MM] [--weekday DAY] [--dry-run]"* ]] || false
    [[ "${output}" == *"uninstall"* ]] || false
    [[ "${output}" == *"status"* ]] || false
}

@test "sudo-setup: --help prints the usage, no root needed" {
    run "${SUDO_SETUP}" --help
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"Usage: sudo "* ]] || false
    [[ "${output}" == *"--disable"* ]] || false
}
