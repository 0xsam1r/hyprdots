#!/bin/bash
readonly name=$1

if [[ $name == "samir" ]] ; then 
	echo "Welcome SPECTRE"
elif [[ $name == "ahmed" ]] ; then
	echo "Welcome admin"
else
	echo "Welcome $name"
fi
