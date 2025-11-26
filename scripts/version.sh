#!/bin/bash
set -e

BUMP=${1:-patch}
RELEASE_TYPE=${2:-snapshot}

git fetch --tags

LAST_RELEASE_TAG=$(git tag --sort=-creatordate | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)
if [[ -z "$LAST_RELEASE_TAG" ]]; then
  LAST_RELEASE_TAG="v0.0.0"
fi
LAST_RELEASE_VERSION=${LAST_RELEASE_TAG#v}

ARTIFACT_FILE="snapshot-version.txt"

if [[ -f "$ARTIFACT_FILE" ]]; then
  source "$ARTIFACT_FILE"
else
  BASE_VERSION=$LAST_RELEASE_VERSION
  COUNTER=0
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

  BASE_VERSION=$NEW_VERSION
  COUNTER=0
else
  if [[ "$BASE_VERSION" != "$LAST_RELEASE_VERSION" ]]; then
    BASE_VERSION=$LAST_RELEASE_VERSION
    COUNTER=1
  else
    COUNTER=$((COUNTER+1))
  fi
  NEW_VERSION="${BASE_VERSION}-SNAPSHOT.${COUNTER}"
fi

echo "BASE_VERSION=$BASE_VERSION" > "$ARTIFACT_FILE"
echo "COUNTER=$COUNTER" >> "$ARTIFACT_FILE"

echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
echo "Calculated version: $NEW_VERSION"
