#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

filename=$( basename "$1" )
extension="${filename##*.}"

if [[ "$extension" == "dmg" ]]; then 
	sh "$DIR/dmg.sh" "$1"
fi

if [[ "$extension" == "app" ]]; then 
	sh "$DIR/app.sh" "$1"
fi

if [[ "$extension" == "pkg" ]]; then 
	sh "$DIR/pkg.sh" "$1"
fi

if [[ "$extension" == "zip" ]]; then 
	sh "$DIR/zip.sh" "$1"
fi
