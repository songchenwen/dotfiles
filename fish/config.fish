set -x ANDROID_HOME ~/Documents/android-sdk-macosx

set -x PATH $HOME/.rvm/scripts/rvm $ANDROID_HOME/build-tools/19.1.0 $ANDROID_HOME/platform-tools $PATH

set -x LSCOLORS gxBxhxDxfxhxhxhxhxcxcx

source ~/.config/fish/z.fish

source ~/.config/fish/rvm.load

abbr -a s2t 'pbpaste | opencc -c s2twp.json | pbcopy'
abbr -a aria2c aria2c -c -s16 -x16
