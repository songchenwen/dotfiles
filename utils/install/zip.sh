#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need a dmg file"
	exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

filename=$( basename "$1" )
extension="${filename##*.}"
filename="${filename%.*}"

dest="$DIR/../tmp/$filename"

unzip -qq "$1" -d "$dest"

cd "$dest"

FILES=$( ls -R | grep .app$ )
if [[ $? == 0 ]]; then
	file=${FILES[0]}
	sh "$DIR/../install/app.sh" "$dest/$file"
	exit 0
fi

FILES=$( ls -R | grep .pkg$ )
if [[ $? == 0 ]]; then
	file=${FILES[0]}
	sh "$DIR/../install/pkg.sh" "$dest/$file"
	exit 0
fi
