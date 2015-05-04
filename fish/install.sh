#!/bin/bash
FISHDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if test ! $(which fish); then
	sh "$FISHDIR/../brew/install.sh"
	echo "Fishshell installing"
	brew install fish
	echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
	chsh -s /usr/local/bin/fish
fi

echo "Fishshell configuring"

cd ~/.config
ln -Fs "$FISHDIR"
