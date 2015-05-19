#!/bin/bash

GEMITEMSDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

APPS=( cocoapods github-pages lunchy )

if test ! $(which rvm); then
	sh "$GEMITEMSDIR/../rvm/install.sh"
fi

for app in ${APPS[@]}
do
gem list $app | grep "$app" > /dev/null
if test ! $?; then
	echo "$app Installing"
	gem install $app
fi
done
