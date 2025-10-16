#!/bin/bash
# main process
	# inial counter for valid paths
	# read inputs
	# handle input paths, 
	# handle commands ex  {-exit, -vp}
	# -vp print counter 
	# -exit print number of valid paths and exit
# check (function)
	# check if path exist using 
	# check type of path {directory or a file}
	# print the meta data using stat cammand
	# increase counter
clear
counter=0
echo "Welcome to path Analyzer :)"
check() {
	path=$1

	if [[ -e $path ]] ; then 
		((counter++))
		[[ -d $path ]] && echo "Oh! $path is a directory"
		[[ -f $path ]] && echo "Oh! $path is a file"
		stat $path
	else
		echo "$path not exist"
	fi 
}

while [[ $path != "-exit" ]] ; do
	read -p "PATH> " path
	case $path in
		"-ls")
				ls ;;
		"-clear")	
	       		clear ;;
		"-help")
			echo "enter path to analysis"
			echo "commands {-help, -clear, -ps, -exit}"
			;;
		"-exit")
			echo "======================="
			echo "Valid paths: $counter" "BYE!....."
			echo "======================="
			exit ;;
		"-vp")	
			echo "Valid paths number: $counter" ;;
		*)
			check $path ;;
	esac
done


		
