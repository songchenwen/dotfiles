#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need an app file"
	exit 1
fi

cp -R -n "$1" /Applications 2> /dev/null
