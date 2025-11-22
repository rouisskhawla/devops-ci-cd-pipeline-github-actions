#!/bin/bash
set -e

BUMP=${1:-patch}
RELEASE_TYPE=${2:-snapshot}
git fetch --tags
LAST_TAG=$(git tag --sort=-creatordate | grep '^v' | head -n1)
if [[ -z "$LAST_TAG" ]]; then
  LAST_TAG="v0.0.0"
fi
echo "Last tag: $LAST_TAG"

VERSION_NO_V=${LAST_TAG#v}
MAJOR=$(echo $VERSION_NO_V | cut -d. -f1)
MINOR=$(echo $VERSION_NO_V | cut -d. -f2)
PATCH=$(echo $VERSION_NO_V | cut -d. -f3 | cut -d- -f1)

case $BUMP in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
  *) echo "Invalid bump type"; exit 1 ;;
esac

if [[ "$RELEASE_TYPE" == "release" ]]; then
  NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
else
  NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}-snapshot"
fi

echo "New version: $NEW_VERSION"
git tag -a "$NEW_VERSION" -m "${RELEASE_TYPE^} $NEW_VERSION"
git push origin "$NEW_VERSION"
echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
