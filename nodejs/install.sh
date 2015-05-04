#!/bin/bash

NODEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if test ! $(which node); then
	sh "$NODEDIR/../brew/install.sh"
	echo "Nodejs installing"
	brew install node
fi