set -x ANDROID_HOME /usr/local/opt/android-sdk

set -x PATH $ANDROID_HOME/bin $ANDROID_HOME/tools $PATH

set -x LSCOLORS gxBxhxDxfxhxhxhxhxcxcx

source ~/.config/fish/z.fish

abbr -a s2t 'pbpaste | opencc -c s2twp.json | pbcopy'
abbr -a g git
abbr -a p pod
abbr -a pu pod update --no-repo-update
abbr -a pi pod install --no-repo-update
