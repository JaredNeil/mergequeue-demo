#!/bin/bash

set -xeuo pipefail

for stack in {1..5}; do
    av switch main
    for pr in {1..5}; do
        touch "files/${stack}_${pr}"
        av commit --all --message "Stack ${stack}.${pr}"
    done
    av pr --all
done
