# rust-ci

Shared CI and release workflows, setup actions and a
[cargo-generate](https://github.com/cargo-generate/cargo-generate) template
for my Rust crates.

## New crate

```sh
cargo generate --git https://github.com/puremourning/rust-ci --name my-crate
# or, from a local checkout
cargo generate --path ~/Development/rust/rust-ci --name my-crate
```

Prompts (all have defaults; pass `--define key=value` or `--silent` to skip):

| Placeholder | Default | Used for |
|---|---|---|
| `description` | TODO | Cargo description, README, crate docs |
| `msrv` | `1.98` | `rust-version`, CI matrix |
| `github_owner` | `puremourning` | repository URL, badges |
| `author` | `Ben Jackson <puremourning@gmail.com>` | Cargo `authors` |
| `copyright_holder` | `Ben Jackson` | LICENSE |
| `miri` | `true` | miri job in CI |
| `year` | current year | LICENSE |

The result is a workspace (`crates/<name>`, edition 2024, MIT) with a nightly
`rust-toolchain.toml`, the house `.rustfmt.toml`, cargo-release metadata,
README/CHANGELOG/CLAUDE.md and thin workflow callers into this repo.

## Reusable workflows

### CI

```yaml
jobs:
  ci:
    uses: puremourning/rust-ci/.github/workflows/ci.yml@v1
    with:
      msrv: "1.98"
```

| Input | Default | |
|---|---|---|
| `msrv` | required | Added to the test matrix |
| `toolchains` | `["stable", "beta", "nightly"]` | JSON list |
| `runners` | `["ubuntu-latest"]` | JSON list; test matrix is runners × toolchains |
| `nightly-allow-failure` | `true` | |
| `cargo-args` | `--workspace` | Package selection for build/test/clippy/doc |
| `working-directory` | `.` | |
| `fmt-unstable` | `true` | `--unstable-features --error-on-unformatted` |
| `docs` | `true` | `cargo doc` with `RUSTDOCFLAGS=-Dwarnings` |
| `miri` | `false` | |
| `miri-args` | `--workspace` | |
| `miriflags` | `""` | |

Each job sets `RUSTUP_TOOLCHAIN`, so the matrix really tests the toolchain it
names rather than whatever `rust-toolchain.toml` pins. Add project-specific
checks as extra jobs next to `ci`; set `concurrency` in the caller.

### Release

```yaml
on:
  workflow_dispatch:
    inputs:
      version: { required: true, type: string }
permissions:
  contents: write
jobs:
  release:
    uses: puremourning/rust-ci/.github/workflows/release.yml@v1
    with:
      version: ${{ inputs.version }}
    secrets:
      CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

Inputs: `version` (SemVer or `patch`/`minor`/`major`), `dry-run`, `cargo-args`,
`working-directory`. Runs the tests, then `cargo release` (configured by
`[workspace.metadata.release]`), then `gh release create --generate-notes`.
Non-dry runs must be on `main`.

## System dependencies: the setup hook

The workflows know nothing about capnp, apt packages and so on. Instead,
every job runs the caller's `.github/actions/setup/action.yml`, if it exists,
right after installing the toolchain. For example:

```yaml
name: Setup
description: Project setup hook
runs:
  using: composite
  steps:
    - uses: puremourning/rust-ci/setup-capnproto@v1
      with:
        version: "1.3.0"
```

Use `runner.os` inside the hook for per-OS steps.

### `setup-capnproto`

Builds Cap'n Proto from source and puts `capnp` on `PATH`. By default it
builds a release tarball: input `version` (default `1.3.0`).

To build from git instead, e.g. a fork, set `repository` and `ref` (a branch,
tag or commit SHA). The ref is resolved to its commit on every run and the
build is cached on that commit, so pushing to the branch triggers a rebuild.
Git builds use CMake, since a checkout has no `configure` script. Cap'n
Proto 2.x needs C++23, which the Linux runners' default g++ can't build
(13 lacks `<print>`; 14 hits an internal compiler error), so on Linux the
action uses the newest installed `clang++-N` (installing `clang` if there is
none). The `cxx` input overrides the choice.

```yaml
    - uses: puremourning/rust-ci/setup-capnproto@v1
      with:
        repository: https://github.com/you/capnproto
        ref: my-branch
```

Builds are cached per OS, arch and version (or commit).

## Development

- `scripts/regen-fixture.sh` renders `template/` into `tests/fixture`; commit
  the result. The self-test fails if they drift.
- The self-test runs the CI workflow on the fixture (Linux and macOS, with
  miri, through this repo's own setup hook) and lints every workflow. Run it
  manually with *release* ticked to dry-run the release workflow.
- Versioning: tags `vX.Y.Z` plus a moving major tag `v1` that callers use.
  Breaking input changes mean `v2`.
- Releasing: run the *Self-release* workflow on `main` with a patch, minor
  or major bump. It needs a passing Self-test on that commit, tags it as the
  next `vX.Y.Z`, moves the major tag to it, and creates a GitHub release.
  Tick *dry-run* to see the tags without pushing.

## License

[MIT](LICENSE).
