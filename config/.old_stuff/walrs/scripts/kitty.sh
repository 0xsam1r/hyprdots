#!/usr/bin/env bash
 

kitty() {
	echo "daj"
	if command -v kitty >/dev/null && pgrep kitty >/dev/null; then
        command kitty @ set-colors --all "$1/wal/kitty-colors.conf"
        echo "Kitty: kitty colorscheme set"
    fi
}

kitty "$HOME/.cache"
echo "done"
