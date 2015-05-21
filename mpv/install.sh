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

mkdir -p ~/.config

cd ~/.config

ln -Fs "$MPVDIR"
mkdir -p "$MPVDIR/watch_later"

APPFILE=/Applications/mpv.app

if [ ! -e "$APPFILE" ]; then
   	exit
fi

BUNDLEID=$(mdls -name kMDItemCFBundleIdentifier -r $APPFILE)

EXTS=( 3GP ASF AVI FLV M4V MKV MOV MP4 MPEG MPG MPG2 MPG4 RMVB WMV )

if test ! $(which duti); then
	sh "$MPVDIR/../brew/install.sh"
	echo "duti installing"
	brew install duti
fi

for ext in ${EXTS[@]}
do
	lower=$(echo $ext | awk '{print tolower($0)}')
	duti -s $BUNDLEID $ext all
	duti -s $BUNDLEID $lower all
done
