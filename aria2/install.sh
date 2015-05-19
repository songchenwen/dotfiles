#!/bin/bash

ARIA2DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if test ! $(which aria2c); then
	sh "$ARIA2DIR/../brew/install.sh"
	echo "aria2 installing"
	brew install aria2
fi

echo "aria2 configuring"

mkdir -p ~/.aria2

ln -Fs "$ARIA2DIR/aria2.conf" ~/.aria2
