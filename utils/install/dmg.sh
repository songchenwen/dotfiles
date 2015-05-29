#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need a dmg file"
	exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

filename=$( basename "$1" )
extension="${filename##*.}"
filename="${filename%.*}"

mountpoint="/Volumes/$filename"

hdiutil mount -quiet -nobrowse -noidme -noverify -noautoopen -mountpoint "$mountpoint" "$1"

if [[ $? != 0 ]]; then
	echo "Mount $filename failed"
	rm -f "$1"
	exit 1
fi

FILES=$( ls "$mountpoint" )

for file in ${FILES[@]}
do
	filename=$( basename "$file" )
	sh "$DIR/file.sh" "$mountpoint/$filename"
done

hdiutil unmount "$mountpoint"

rm -f "$1"
