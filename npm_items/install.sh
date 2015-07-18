#!/bin/bash

NPMITEMSDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

APPS=( trash yo generator-hubot coffee-script nw )

if test ! $(which node); then
	sh "$NPMITEMSDIR/../nodejs/install.sh"
fi

for app in ${APPS[@]}
do
if test ! $(which $app); then
	echo "$app Installing"
	npm install --global $app
fi
done
