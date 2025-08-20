#!/bin/bash

# This script aims to traverse all subdirectories and execute 'git pull' in each one.

dirs=$(fd -E "go" -E "yay" -E ".vscode" -E ".local" -E ".config" -E ".tmux" -H "^(\.git)$" "$HOME" -X echo {//})

for dir in $dirs; do
    if [ -d "$dir" ]; then
        echo "Pulling updates in: $dir"
        cd "$dir"
        if [[ $(git status | grep "Changes" | wc -l) -gt 0 ]]; then
            git stash
        fi

        git pull

        if [[ $(git stash list | wc -l) -gt 0 ]]; then
            git stash pop
        fi
        cd - > /dev/null
    else
        echo "Directory $dir does not exist."
    fi
done
