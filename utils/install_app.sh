#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need a link to install"
	exit 1
fi

if [[ -z "$2" ]]; then
	echo "Need a app name"
	exit 1
fi

APP="/Applications/$2.app"
if [[ -e $APP ]]; then
	echo "$2.app is already installed"
	exit 0
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

sh "$DIR/../aria2/install.sh"

mkdir -p "$DIR/tmp"

cd "$DIR/tmp"

rm -rf ./*

echo "$2 Downloading"
aria2c "$1"
if [[ $? != 0 ]]; then
	echo "$2 Downloading failed"
	exit 1
fi

echo "$2 Installing"
FILES=$( ls )

for file in ${FILES[@]}
do
	filename=$( basename "$file" )
	sh "$DIR/install/file.sh" "$DIR/tmp/$filename"
done

rm -rf ./*
