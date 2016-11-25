#!/bin/bash

KARABINERDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Karabiner configuring"

rm -rf ~/.karabiner.d
ln -Fs "$KARABINERDIR" ~/.karabiner.d

