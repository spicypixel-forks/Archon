#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-dev}"
TARGET_BRANCH="${TARGET_BRANCH:-dev-patched}"
PATCH_LIST="${PATCH_LIST:-.github/patch-branches.txt}"

git fetch origin '+refs/heads/*:refs/remotes/origin/*'

git switch -C "$TARGET_BRANCH" "origin/$BASE_BRANCH"
git branch --set-upstream-to="origin/$TARGET_BRANCH"

git show "origin/automation:$PATCH_LIST" > /tmp/patch-branches.txt

while IFS= read -r branch; do
  [[ -z "$branch" || "$branch" =~ ^# ]] && continue
  echo "Merging $branch"
  git merge --no-ff --no-edit "origin/$branch"
done < /tmp/patch-branches.txt

git push origin "$TARGET_BRANCH" --force-with-lease