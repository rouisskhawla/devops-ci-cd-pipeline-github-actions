#!/bin/bash
set -euo pipefail

BUMP=${1:-patch}
MODE=${2:-deploy}

git fetch --tags

LAST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)

if [[ -z "$LAST_TAG" ]]; then
  LAST_TAG="v0.0.0"
fi

LAST_VERSION=${LAST_TAG#v}

MAJOR=$(echo "$LAST_VERSION" | cut -d. -f1)
MINOR=$(echo "$LAST_VERSION" | cut -d. -f2)
PATCH=$(echo "$LAST_VERSION" | cut -d. -f3)

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *) echo "Invalid bump type: $BUMP"; exit 1 ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

if [[ "$MODE" == "release" ]]; then
  git config user.name "github-actions"
  git config user.email "actions@github.com"

  TAG_NAME="v${NEW_VERSION}"
  git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
  git push origin "$TAG_NAME"
fi

echo "version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
echo "Calculated version: $NEW_VERSION"
