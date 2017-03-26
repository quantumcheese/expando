set -e
set -x

if ! which swiftlint >/dev/null; then
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
  exit 1
fi

#PBXPROJ="${SRCROOT}/$(basename "${SRCROOT}" | tr '[:upper:]' '[:lower:]').xcodeproj/project.pbxproj"
#if [ -f "${PBXPROJ}" ]; then
  #echo found pbxproj:  ${PBXPROJ}
#else
  #echo "error: ${PBXPROJ} not found ):"
#fi

swiftlint
