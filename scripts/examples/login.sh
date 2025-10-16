#!/bin/bash
counter=0
while [[ $counter -lt 3 ]] ; do
	read -p "Enter username> " user
	case $user in 
		"samir")
			echo "$user allowed" ;;
		"admin") 
			echo "$user allowed" ;;
		"exit")
			echo "exiting......"
			exit ;;
		*)
			echo "$user not allowed"
			counter=$((counter + 1))
	esac
done

