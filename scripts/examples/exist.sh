#!/bin/bash

readonly file=$1

if [[ -e $file ]] ; then 
	echo "\"$file\" exist"

	# conditions on the fly
	[[ -f $file ]] && echo "\"$file\" is a ordinary file"
	[[ -d $file ]] && echo "\"$file\" is a directory"
else
	echo "$file not exist"
fi
