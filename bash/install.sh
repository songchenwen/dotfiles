#!/bin/bash

BASHDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd ~

ln -Fs "$BASHDIR/bash_profile" .bash_profile
