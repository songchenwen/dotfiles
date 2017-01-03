#!/bin/bash

KARABINERDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Karabiner configuring"

rm -rf ~/.config/karabiner/karabiner.json
ln -Fs "$KARABINERDIR/karabiner.json" ~/.config/karabiner/karabiner.json

