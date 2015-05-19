#!/bin/bash

YOUTUBEDLDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if test ! $(which youtube-dl); then
	sh "$YOUTUBEDLDIR/../brew/install.sh"
	echo "youtube-dl installing"
	brew install youtube-dl
fi

echo "youtube-dl configuring"

mkdir -p ~/.config

cd ~/.config
ln -Fs "$YOUTUBEDLDIR"
