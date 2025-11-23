#!/bin/bash
set -e

BUMP=${1:-patch}
RELEASE_TYPE=${2:-snapshot}

git fetch --tags

LAST_RELEASE_TAG=$(git tag --sort=-creatordate | grep -v 'SNAPSHOT' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)
if [[ -z "$LAST_RELEASE_TAG" ]]; then
  LAST_RELEASE_TAG="v0.0.0"
fi
LAST_RELEASE_VERSION=${LAST_RELEASE_TAG#v}

LAST_SNAPSHOT_FILE="snapshot-version.txt"

if [[ ! -f "$LAST_SNAPSHOT_FILE" ]]; then
  echo "BASE_VERSION=$LAST_RELEASE_VERSION" > "$LAST_SNAPSHOT_FILE"
  echo "COUNTER=0" >> "$LAST_SNAPSHOT_FILE"
fi

if [[ "$RELEASE_TYPE" == "release" ]]; then
  MAJOR=$(echo $LAST_RELEASE_VERSION | cut -d. -f1)
  MINOR=$
