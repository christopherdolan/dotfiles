#!/bin/bash

echo "This will wipe out any rcfiles in your $HOME directory."
echo -ne "Are you sure? [y/N] "
read

if [[ $REPLY =~ [yY] ]]; then
	rc_files=$(ls -a $HOME | grep "^\..*rc")
	for rc_file in $rc_files; do
		rm -v $HOME/$rc_file
	done
else
	exit 1
fi

