#!/bin/bash

if test ! $(which brew); then
	echo "Brew installing "
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
