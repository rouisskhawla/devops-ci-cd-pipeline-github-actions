#!/bin/bash
set -e

BUMP=${1:-patch}
RELEASE_TYPE=${2:-snapshot}
GITHUB_RUN_NUMBER=${GITHUB_RUN_NUMBER:-0}

git fetch --tags

LAST_RELEASE_TAG=$(git tag --sort=-creatordate | grep -v 'SNAPSHOT' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)
if [[ -z "$LAST_RELEASE_TAG" ]]; then
  LAST_RELEASE_TAG="v0.0.0"
fi
BASE_VERSION=${LAST_RELEASE_TAG#v}

MAJOR=$(echo $BASE_VERSION | cut -d. -f1)
MINOR=$(echo $BASE_VERSION | cut -d. -f2)
PATCH=$(echo $BASE_VERSION | cut -d. -f3)

if [[ "$RELEASE_TYPE" == "release" ]]; then
  case $BUMP in
    major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR+1)); PATCH=0 ;;
    patch) PATCH=$((PATCH+1)) ;;
    *) echo "Invalid bump type: $BUMP"; exit 1 ;;
  esac
  NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
else
  LAST_SNAPSHOT_TAG=$(git tag --sort=-creatordate | grep "v$BASE_VERSION-SNAPSHOT" | head -n1)

  if [[ -z "$LAST_SNAPSHOT_TAG" ]]; then
    SNAPSHOT_COUNTER=1
  else
    SNAPSHOT_COUNTER=$(echo $LAST_SNAPSHOT_TAG | sed -E 's/^v[0-9]+\.[0-9]+\.[0-9]+-SNAPSHOT\.([0-9]+)$/\1/')
    SNAPSHOT_COUNTER=$((SNAPSHOT_COUNTER+1))
  fi

  NEW_VERSION="${BASE_VERSION}-SNAPSHOT.${SNAPSHOT_COUNTER}"
fi

TAG_NAME="v$NEW_VERSION"

git config user.name "github-actions"
git config user.email "actions@github.com"

git tag -a "$TAG_NAME" -m "${RELEASE_TYPE^} $TAG_NAME"
git push origin "$TAG_NAME"

echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
echo "Git tag created: $TAG_NAME"
