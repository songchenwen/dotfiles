#!/bin/bash

MPVDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if test ! $(which mpv); then
	sh "$MPVDIR/../brew/install.sh"
	echo "mpv installing "
	brew tap mpv-player/mpv
	brew install mpv
	brew linkapps mpv
fi


echo "mpv configuring"

cd ~/.config

ln -Fs "$MPVDIR"
mkdir -p "$MPVDIR/tmp"
mkdir -p "$MPVDIR/watch_later"
touch "$MPVDIR/tmp/icc-cache"
