#!/bin/bash

if test ! $(which rvm); then
	echo "rvm installing"
	\curl -sSL https://get.rvm.io | bash -s stable
fi
