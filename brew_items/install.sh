#!/bin/bash

ITEMDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
sh "$ITEMDIR/../brew/install.sh"

brew install aria2 git opencc tag openssl duck
brew link openssl
brew link git
