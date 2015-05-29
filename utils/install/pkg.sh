#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need a pkg file"
	exit 1
fi

installer -package "$1" -target "/Volumes/Macintosh HD"
