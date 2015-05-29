#!/bin/bash

xcode-select --install 2> /dev/null

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

sh "$DIR/apps/install_apps.sh"

chmod +x $DIR/*/install.sh
ls $DIR/*/install.sh | sh
