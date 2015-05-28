#!/bin/bash

GITDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd ~

ln -Fs "$GITDIR/gitconfig" .gitconfig
ln -Fs "$GITDIR/gitignore_global" .gitignore_global
