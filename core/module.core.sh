#!/bin/bash

	# NOTE THAT ALL ARRAY CONVERSIONS ARE DONE ON A GLOBAL SCOPE - AS BASH CAN'T HANDLE ARRAY REFERENCES FROM/TO FUNCTIONS


	# STRING TO UPPER CASE
	function toUpperCase() {

		(echo "$1" | tr "[:lower:]" "[:upper:]")
	}

	# STRING TO LOWER CASE
	function toLowerCase() {

		(echo "$1" | tr "[:upper:]" "[:lower:]")
	}

	# CLONE ARRAY
	function clone() {

#		unset $2
		if [ "$1" == "--merge" ]; then

			local current=$2
			local target=$3
		else
			local current=$1
			local target=$2

			eval "unset $target"
		fi

		eval "$target+=(\"\${$current[@]}\")"

#		for key in $1[@]; do
#			push $2 "$key"
#		done
	}

	# MAX LENGTH OF ARRAY VALUE
	function maxLength() {

		local width=0
		local n=0

		for key in ${i[@]}; do

			n=$((${#i[$k]}))

			if [ "$n" -gt "$width" ]; then

				width=$n
			fi
		done

		echo $n
	}

	# PUSH ARRAY
	function push() {

		eval "$1+=(\"$2\")"
	}

	# SPLIT STRING TO ARRAY
	function split() {

		for i in $(echo $1 | tr "$2" "\n"); do
			push $3 "$i"
		done
	}

	# LENGTH OF ARRAY
	function length() {

		eval echo "\${#$1[@]}"
	}

	# CHECK IF ARGUMENT IS NUMERIC
	function isNumeric() {

		local _isNumeric=false

		test "$1" -ge 0 -o "$1" -lt 0 2>&- && _isNumeric=true

		echo $_isNumeric
	}

	# GET ARRAY WIDTH
	function arrayWidth() {

		local w=0

		clone $1 tmp

		# GET LONGEST WIDTH OF ARRAY CONTENT
		for k in ${!tmp[@]}; do

			n=$(textTrimColor "${tmp[$k]}")
			n=${#n}

			if [ "$n" -gt "$w" ]; then
				w=$n
			fi
		done

		echo $w
	}

	# ALIGN VERTICAL AND HORIZONTAL INPUT
	function setTextAlign() {

		local x=$(textAlignX "$1")
		local y=$(textAlignY "$1")

		tput cup $y $x
	}

	# CALCULATES Y COORDINATE OFFSET FOR VERTICAL ALIGN
	function textAlignY() {

		local screenHeight=$(tput lines)
		local y
		
		y=$(($screenHeight/2))

		echo $y
	}

	# TAKES AN ARRAY OF TEXT AND CALCULATES Y COORDINATE OFFSET
	function arrayAlignY() {

		local screenHeight=$(tput lines)
		local y=0
		clone $1 __tmpArray__
		local textHeight=$(length __tmpArray__)
		
		y=$((($screenHeight-$textHeight)/(2)))

		if [ "$y" -lt 0 ]; then
			$y=0
		fi

		echo $y
	}

	# TAKES A STRING OF TEXT AND CALCULATES X COORDINATE OFFSET
	function textAlignX() {

		local screenWidth=$(tput cols)
		local x=0
		local textWidth=$(textTrimColor "$1")

		textWidth=${#textWidth}
		x=$((($screenWidth-$textWidth)/(2)))

		if [ "$x" -lt 0 ]; then
			$x=0
		fi

		echo $x
	}

	# TAKES AN ARRAY OF TEXT AND CALCULATES X COORDINATE OFFSET
	function arrayAlignX() {

		local screenWidth=$(tput cols)
		local textWidth=0
		local x=0
		local n=0

		clone $1 __tmpArray__

		# GET LONGEST WIDTH OF ARRAY CONTENT
		for k in ${!__tmpArray__[@]}; do

			n=$(textTrimColor "${__tmpArray__[$k]}")
			n=${#n}

			if [ "$n" -gt "$textWidth" ]; then
				textWidth=$n
			fi
		done
		
		x=$((($screenWidth-$textWidth)/(2)))

		if [ "$x" -lt 0 ]; then
			$x=0
		fi

		echo $x
	}

	# REMOVE COLOR CODE FROM TEXT (USEFUL FOR CALCULATING CORRECT WIDTH OF TEXT STRING)
	function textTrimColor() {

		local output="$1"
		output=$(echo "$output" | sed 's/\\e\[[0-9];[0-9][0-9]m//g')
		output=$(echo "$output" | sed 's/\\e\[[0-9]m//g')

		echo "$output"
	}

	# COLOR PICKER
	function color {

		local color=""
		local output=""
		local default="\e[0m"

		if [ "$1" == "black" ]; then
			color="\e[1;90m"
		fi

		if [ "$1" == "red" ]; then
			color="\e[1;31m"
		fi

		if [ "$1" == "green" ]; then
			color="\e[1;32m"
		fi

		if [ "$1" == "yellow" ]; then
			color="\e[1;33m"
		fi

		if [ "$1" == "blue" ]; then
			color="\e[1;34m"
		fi

		if [ "$1" == "purple" ]; then
			color="\e[1;35m"
		fi

		if [ "$1" == "cyan" ]; then
			color="\e[1;36m"
		fi

		if [ "$1" == "white" ]; then
			color="\e[1;37m"
		fi

		if [ "$2" ]; then
			output="${color}${2}${default}"
		elif [ "$color" ]; then
			output="${color}"
		else
			output="${default}"
		fi

		echo "${output}"
	}

	function initProgram() {

		stty -echo
		tput civis
	}

	function exitProgram() {

		stty echo
		tput cnorm
		exit
	}
