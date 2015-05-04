#!/bin/bash

if test ! $(which rvm); then
	echo "rvm installing"
	\curl -sSL https://get.rvm.io | bash -s stable
fi

if test ! $(which pod); then
	echo "cocoapods installing"
	gem install cocoapods
fi

gem list github-pages | grep "github-pages"
if test ! $?; then
	echo "github-pages installing"
	gem install github-pages
fi
