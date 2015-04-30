# [mpv] Configs

My configuration files for [mpv]

## [mpv]

[mpv] is a free and open source video player, which forked from mplayer2 and MPlayer. 

[mpv] outputs high quality video with efficient algorithms. It's under active development now.

## Configs

Here are my [mpv] configuration files on OS X.

These configurations enable hardware decoding and a simple UI.

Some automation is added to [mpv].

- Automatically mark video file as finished by removing the `Unfinished` finder tag.
- Automatically add files with similar name in the same directory to play list.

## Install [mpv]

~~~ bash
brew tap mpv-player/mpv
brew install mpv
brew linkapps mpv
~~~

## Use these configs

[mpv] will load files in `~/.config/mpv` as configurations automatically. Just put these files there.

[mpv]:http://mpv.io
