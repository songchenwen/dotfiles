set -x ANDROID_HOME ~/Documents/android-sdk-macosx

set -x PATH $HOME/.rvm/scripts/rvm $ANDROID_HOME/build-tools/19.1.0 $ANDROID_HOME/platform-tools $PATH

set -x LSCOLORS gxBxhxDxfxhxhxhxhxcxcx

source ~/.config/fish/z.fish

if test -z $rvm_bin_path
  exec bash --login -c "exec fish" ^&1
end
