#!/usr/bin/env bash
# Render template/ into tests/fixture with fixed values, so the self-test can
# check the committed render is up to date and run the shared workflows on it.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT

cargo generate \
  --path "$root" template \
  --name fixture \
  --destination "$out" \
  --vcs none \
  --silent \
  --define description="Fixture rendered from the rust-ci template" \
  --define year=2026

rm -rf "$root/tests/fixture"
mv "$out/fixture" "$root/tests/fixture"
