#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

urls=("https://pqrs.org/osx/karabiner/files/Karabiner-10.6.0.dmg"
	  "https://pqrs.org/osx/karabiner/files/Seil-11.1.0.dmg"
	  "https://iterm2.com/downloads/stable/iTerm2_v2_0.zip"
	  "https://github.com/Hammerspoon/hammerspoon/releases/download/0.9.31/Hammerspoon-0.9.31.zip"
	  "http://downloads.atlassian.com/software/sourcetree/SourceTree_2.0.5.2.dmg"
	   "https://github.com/ohdarling/GoAgentX/releases/download/rel-v2.3.7/GoAgentX-v2.3.7.dmg"
	   "http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg")

names=("Karabiner"
	   "Seil"
	   "iTerm"
	   "Hammerspoon"
	   "SourceTree"
	   "GoAgentX"
	   "QQ")

urlcount=${#urls[@]}
namecount=${#names[@]}
if [[ $urlcount !=  $namecount ]]; then
	echo "urls $urlcount and names $namecount count not match"
	exit 1
fi

for(( i=0; i<urlcount; i++ )); do
	url=${urls[$i]}
	name=${names[$i]}
	sh "$DIR/../utils/install_app.sh" "$url" "$name"
done
