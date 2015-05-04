#!/bin/bash
MAIDDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if test ! $(which maid); then
	echo "maid installing"
	sh "$MAIDDIR/../rvm/install.sh"
	gem install maid
fi

echo "Maid configuring rules"

cd ~/.config
ln -Fs "$MAIDDIR/rules.rb" ~/.maid/rules.rb
