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
  MINOR=$(echo $LAST_RELEASE_VERSION | cut -d. -f2)
  PATCH=$(echo $LAST_RELEASE_VERSION | cut -d. -f3)

  case $BUMP in
    major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR+1)); PATCH=0 ;;
    patch) PATCH=$((PATCH+1)) ;;
    *) echo "Invalid bump type: $BUMP"; exit 1 ;;
  esac

  NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
  TAG_NAME="v$NEW_VERSION"

  git config user.name "github-actions"
  git config user.email "actions@github.com"
  git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
  git push origin "$TAG_NAME"

  echo "BASE_VERSION=$NEW_VERSION" > "$LAST_SNAPSHOT_FILE"
  echo "COUNTER=0" >> "$LAST_SNAPSHOT_FILE"

else
  source "$LAST_SNAPSHOT_FILE"

  if [[ "$BASE_VERSION" != "$LAST_RELEASE_VERSION" ]]; then
    BASE_VERSION=$LAST_RELEASE_VERSION
    COUNTER=1
  else
    COUNTER=$((COUNTER+1))
  fi

  NEW_VERSION="${BASE_VERSION}-SNAPSHOT.${COUNTER}"

  echo "BASE_VERSION=$BASE_VERSION" > "$LAST_SNAPSHOT_FILE"
  echo "COUNTER=$COUNTER" >> "$LAST_SNAPSHOT_FILE"
fi

echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
echo "Calculated version: $NEW_VERSION"
