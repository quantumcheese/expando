#!/bin/bash
set -e
set -x

function is_upgradeable {
  return $(brew outdated) | grep "swiftlint"
}

if which swiftlint >/dev/null; then
  if ! is_upgradeable ; then
    exit 0
  fi
  COMMAND="upgrade"
else
  COMMAND="install"
fi

brew update && brew "${COMMAND}" swiftlint
swiftlint version
