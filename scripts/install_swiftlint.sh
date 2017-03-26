#!/bin/bash
set -e
set -x

if which swiftlint >/dev/null; then
  COMMAND="upgrade"
else
  COMMAND="install"
fi

brew update && brew "${COMMAND}" swiftlint
swiftlint version
