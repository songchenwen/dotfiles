#!/bin/bash
MAIDDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if test ! $(which maid); then
	sh "$MAIDDIR/../rvm/install.sh"
	echo "maid installing"
	gem install maid
fi

if test ! $(which cpulimit); then
	sh "$MAIDDIR/../brew/install.sh"
	brew install cpulimit
fi

echo "Maid configuring rules"

cd ~/.config
ln -Fs "$MAIDDIR/rules.rb" ~/.maid/rules.rb

RUNSH="$MAIDDIR/run.sh"
if [ ! -e "$RUNSH" ]; then
   	echo "Maid generating run.sh"
   	PATHTORUBY=$(which ruby)
   	PATHTOMAID=$(which maid)
   	PATHCPULIMIT=$(which cpulimit)
   	cat "$MAIDDIR/run.sh.temp" | sed "s|PATHCPULIMIT|$PATHCPULIMIT|" | sed "s|PATHTORUBY|$PATHTORUBY|" | sed "s|PATHTOMAID|$PATHTOMAID|" | sed "s|HOMEPATH|$HOME|" > $RUNSH
   	chmod +x $RUNSH
fi

launchctl list | grep -q -E 'com.songchenwen.maid'
if [[ $? != 0 ]]; then
	echo "Maid adding launch agent"

	cat "$MAIDDIR/com.songchenwen.maid.plist.temp" | sed "s|PATHTO|$MAIDDIR|" > ~/Library/LaunchAgents/com.songchenwen.maid.plist
	launchctl load ~/Library/LaunchAgents/com.songchenwen.maid.plist
fi
