#!/bin/bash

SEILDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Seil configuring"

ln -Fs $SEILDIR/org.pqrs.Seil.plist ~/Library/Preferences/
