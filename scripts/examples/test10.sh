#!/bin/bash

read -p "Enter a number: " num
if [[ $num -gt 10 ]] ; then
	echo "greater than"
elif [[ $num -eq 10 ]] ; then 
	echo "equal"
else 
	echo "less than"
fi
