#!/bin/bash

	WORK_DIR="$(pwd)"

	source ${WORK_DIR}/core/module.core.sh

###
###	COLOR TEXT ALERTER AND ANIMATED LOADER FOR GNU MAKE (Believe you me, this was the "easiest" way to do it...)	/ FM
###

	_brackets="black"
	_message=""
	_pid=""

	SECONDS=0
	MINUTES=0
	SEC=0
	MIN=0
			
        function get-time {

		OUTPUT="00:00"

		if [ $SECONDS -lt 10 ]; then

			SEC="0${SECONDS}"
		else
			SEC=$SECONDS
		fi

		if [ $MINUTES -lt 10 ]; then

			MIN="0${MINUTES}"
		else
			MIN=$MINUTES
		fi

                if [ $SECONDS == 60 ]; then

			SECONDS=0
			SEC="00"
			MINUTES=$((MINUTES+1))

			if [ $MINUTES -lt 10 ]; then

				MIN="0${MINUTES}"
			else
				MIN=$MINUTES
			fi
                fi  

		echo -en "$MIN:$SEC"
        }	

	function loader-beginning {

		echo -en $(color black)
		echo -en "    [ "
		echo -en $(color blue "$_message: ")
		echo -en $(color)
	}

	function loader-character {
		echo -en '• '
	}

	function loader-end {

		local delay=0.5

		echo -en $(color black)
		echo -en "] - ("
		get-time
		echo -en ")\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
		echo -en $(color)
		sleep $delay
	}

	function loader-start {

		tput civis

		cmd="(${1})"

		printf "\n"
		`eval $cmd` & loader $!
	}

	function loader {

		while [ -d /proc/$1 ]; do

			loader-beginning
			echo -en $(color blue)
			loader-character
			echo -en $(color black)
			loader-character
			loader-character
			loader-end $t
			
			loader-beginning
			echo -en $(color black)
			loader-character
			echo -en $(color blue)
			loader-character
			echo -en $(color black)
			loader-character
			loader-end $t
			
			loader-beginning
			echo -en $(color black)
			loader-character
			loader-character
			echo -en $(color blue)
			loader-character
			loader-end $t

			loader-beginning
			echo -en $(color black)
			loader-character
			loader-character
			loader-character
			loader-end $t

			echo -en $(color)
			sleep 0.5
		done

		echo -en $(color black)
		echo -en '    [ '
		echo -en $(color blue)
		echo -en "$_message: DONE"
		echo -en $(color black)
		echo -en ' ] - ('
		get-time
		echo -en ')'
		echo -en '                                                                            '
		echo -en $(color)
		printf "\n\n"

		tput cnorm
	}


	if [ "$1" == "warning" ]; then

		_color="yellow"
		_message="WARNING"

		if [ "$2" != "" ]; then
			_text=$2
		fi
	fi

	if [ "$1" == "error" ]; then

		_color="red"
		_message="ERROR"

		if [ "$2" != "" ]; then
			_text=$2
		fi
	fi

	if [ "$1" == "ok" ]; then

		_color="green"
		_message="OK"

		if [ "$2" != "" ]; then
			_text=$2
		fi
	fi

	if [ "$1" == "text" ]; then

		_color="blue"
		_message="$2"

		if [ "$3" != "" ]; then
			_color=$3
		fi
	fi

	if [ "$1" == "done" ]; then

		_color="blue"
		_message="DONE"

		if [ "$2" != "" ]; then
			_text=$2
		fi
	fi

	if [ "$1" == "load" ]; then

		_color="blue"
		_message="$2"
		_load="1"

		loader-start "$3"

		exit
	fi

	if [ "$_load" != "1" ]; then

		echo ""
		echo -en $(color $_brackets)
		echo -en "    [ "
		echo -en $(color $_color)

		echo -en "$_message"

		if [ -n "$_text" ]; then

			echo -en ": "
			echo -en $(color $_color)

			if [ "$3" != "" ]; then
				$(color $3)
			fi

			echo -en "$_text"
		fi

		echo -en $(color $_brackets)
		echo -e " ]"
		echo -en $(color)
		echo ""
	fi
