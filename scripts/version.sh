#!/bin/bash
set -e

# Default: increment PATCH
BUMP=${1:-patch}   # Options: patch (default), minor, major
RELEASE_TYPE=${2:-snapshot} # snapshot or release

# Get last tag
LAST_TAG=$(git describe --tags --match "v*" --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Last tag: $LAST_TAG"

# Remove leading 'v' and split into MAJOR.MINOR.PATCH
VERSION_NO_V=${LAST_TAG#v}
MAJOR=$(echo $VERSION_NO_V | cut -d. -f1)
MINOR=$(echo $VERSION_NO_V | cut -d. -f2)
PATCH=$(echo $VERSION_NO_V | cut -d. -f3 | cut -d- -f1)

# Bump version
case $BUMP in
  major)
    MAJOR=$((MAJOR+1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR+1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH+1))
    ;;
  *)
    echo "Invalid bump type: $BUMP"
    exit 1
    ;;
esac

# Create new version string
if [[ "$RELEASE_TYPE" == "release" ]]; then
  NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
else
  NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}-snapshot"
fi

echo "New version: $NEW_VERSION"

# Optionally, create git tag if release
if [[ "$RELEASE_TYPE" == "release" ]]; then
  git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"
fi

# Output version for GitHub Actions
echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
