#!/bin/bash

KARABINERDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Karabiner configuring"

mkdir -p ~/Library/Application\ Support/Karabiner/
ln -Fs "$KARABINERDIR/private.xml" ~/Library/Application\ Support/Karabiner/

ln -Fs $KARABINERDIR/org.pqrs.Seil.plist ~/Library/Preferences/
