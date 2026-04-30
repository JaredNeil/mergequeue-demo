#!/bin/bash
set -xe

# Create some PRs
git switch main
git switch -c branch-1
git commit --allow-empty -m "Commit on branch 1"
git push
gh pr create --title "PR from branch 1" --body ""
branch_1_pr=$(gh pr view --json title,number)

git switch main
git switch -c branch-2
git commit --allow-empty -m "Commit on branch 2"
git push
gh pr create --title "PR from branch 2" --body ""
branch_2_pr=$(gh pr view --json title,number)

git switch main
git switch -c branch-3
git commit --allow-empty -m "Commit on branch 3"
git push
gh pr create --title "PR from branch 3" --body ""
branch_3_pr=$(gh pr view --json title,number)

# Create a merge-queue batch PR
git switch main
git switch -c merge-queue-batch-1
git merge --no-ff --into-name main --no-edit branch-1 --message "Merge pull request #$(jq -r .number <<<"${branch_1_pr}") from lucid-software-internal/branch-1" --message "$(jq -r .title <<<"${branch_1_pr}")"
git merge --no-ff --into-name main --no-edit branch-2 --message "Merge pull request #$(jq -r .number <<<"${branch_2_pr}") from lucid-software-internal/branch-2" --message "$(jq -r .title <<<"${branch_2_pr}")"
git push
gh pr create --draft --title "Merge Queue Batch 1 Draft PR" --body ""

# Create a second merge-queue batch PR, assuming the first batch succeeds
git switch -c merge-queue-batch-2
git merge --no-ff --into-name main --no-edit branch-3 --message "Merge pull request #$(jq -r .number <<<"${branch_3_pr}") from lucid-software-internal/branch-3" --message "$(jq -r .title <<<"${branch_3_pr}")"
git push
gh pr create --draft --title "Merge Queue Batch 2 Draft PR" --body ""

# Merge the first batch
git switch main
git merge --ff-only merge-queue-batch-1
git push

# Merge the second batch
git merge --ff-only merge-queue-batch-2
git push
