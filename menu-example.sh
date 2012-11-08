#!/bin/bash

	# BASH PROGRAM LAUNCHER

	WORK_DIR="$(pwd)"

	source ${WORK_DIR}/core/module.core.sh
	source ${WORK_DIR}/gui/module.gui.sh


	# MAIN MENU
	function showMenu() {

		GUI INIT

		GUI OUTPUT --headline "$(color blue)          DON'T PANIC          $(color)"

		GUI OUTPUT "Do something"
		GUI NAVIGATION --item "callback --something"

		GUI OUTPUT "So something else"
		GUI NAVIGATION --item "callback --something_else"

		GUI OUTPUT "PANIC!"
		GUI NAVIGATION --item "callback --panic" 

		DISPLAY --border --navigation --help
	}


	# MENU CALLBACKS
	function callback() {

		clear
		local exitScreen=true

		# LOOK UP COMMAND
		for key in "$@"; do

			case "$key" in

				"--something")
					local exitScreen=false
					# PLACE YOUR EXTERNAL SCRIPTS/CODE HERE
				;;

				"--something_else")
					local exitScreen=false
					# PLACE YOUR EXTERNAL SCRIPTS/CODE HERE
				;;

				"--panic")
					# PLACE YOUR EXTERNAL SCRIPTS/CODE HERE
				;;
			esac
		done
		
		# SHOW EXIT SCREEN IF APPLICABLE
		if [ "$exitScreen" == true ]; then

			GUI INIT
			local text="PRESS ANY KEY TO CONTINUE"
			setTextAlign "${text}"
			echo -en $(color black "[ ")
			echo -en $(color white "${text}")
			echo -en $(color black " ]")
			read -sN1
		fi

		# RETURN TO MENU
		showMenu
	}

	showMenu
