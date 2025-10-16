#!/bin/bash

read -p "Enter your name: " name
case $name in 
	"samir")
		echo "allowed" ;;
	"ahmed")
		echo "readonly" ;;
	*)
		echo "not allowed $name"
esac
