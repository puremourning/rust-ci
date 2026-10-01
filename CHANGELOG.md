# Changelog

## [Unreleased]

### Added

- Reusable `ci.yml` and `release.yml` workflows with a project setup hook
- `setup-capnproto` composite action
- `setup-capnproto`: `repository` and `ref` inputs to build from a git ref
  (e.g. a fork's branch), cached on the resolved commit
- Self-release workflow: tags `vX.Y.Z`, moves the major tag and creates a
  GitHub release, after a passing self-test
- `setup-capnproto`: git builds use the newest clang on Linux (the default
  g++ can't build Cap'n Proto 2.x); `cxx` input to choose the compiler
- cargo-generate template
