#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

chmod +x $DIR/*/install.sh
ls $DIR/*/install.sh | sh
