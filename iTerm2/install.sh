#!/bin/bash
ITERMDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

sh "$ITERMDIR/../powerline-fonts-patch/install.sh"
echo "iTerm2 configuring"

ln -Fs $ITERMDIR/com.googlecode.iterm2.plist ~/Library/Preferences/

