set -x ANDROID_HOME /usr/local/opt/android-sdk
set -x ANDROID_NDK_HOME /usr/local/opt/android-ndk

set -x PATH $HOME/.rvm/scripts/rvm $ANDROID_HOME/bin $ANDROID_HOME/tools $ANDROID_NDK_HOME/bin $PATH

set -x LSCOLORS gxBxhxDxfxhxhxhxhxcxcx

source ~/.config/fish/z.fish

source ~/.config/fish/rvm.load

abbr -a s2t 'pbpaste | opencc -c s2twp.json | pbcopy'
abbr -a aria2c aria2c -c -s16 -x16
