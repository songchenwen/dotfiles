#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ~

ln -Fs "$DIR/hammerspoon"
rm -f .hammerspoon
mv hammerspoon .hammerspoon

cd ~/.config
ln -Fs "$DIR/fish"

ln -Fs "$DIR/maid_rules/rules.rb" ~/.maid/rules.rb

ln -Fs "$DIR/mpv"
mkdir -p "$DIR/mpv/tmp"
mkdir -p "$DIR/mpv/watch_later"
touch "$DIR/mpv/tmp/icc-cache"
