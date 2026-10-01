# Changelog

## [Unreleased]

### Added

- Reusable `ci.yml` and `release.yml` workflows with a project setup hook
- `setup-capnproto` composite action
- `setup-capnproto`: `repository` and `ref` inputs to build from a git ref
  (e.g. a fork's branch), cached on the resolved commit
- `setup-capnproto`: git builds pick a C++23-capable g++ on Linux (Cap'n
  Proto 2.x); `cxx` input to choose the compiler
- cargo-generate template
