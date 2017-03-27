#!/bin/bash
set -e
set -x

if ! which swiftlint >/dev/null; then
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint/releases/"
  exit 1
fi

swiftlint
