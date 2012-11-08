#!/bin/bash

# MENU EXAMPLE (WITH INPUT)

	WORK_DIR="$(pwd)"

	source ${WORK_DIR}/core/module.core.sh
	source ${WORK_DIR}/gui/module.gui.sh


	# MENU EXECUTION
	function init() {

		# INIT PROGRAM
		initProgram

		GUI OUTPUT --headline "             $(color blue)INPUT EXAMPLE$(color)            "
		GUI INPUT --callback "callback"
		GUI OUTPUT "$(color green)TYPE HERE:$(color) "

		GUI DISPLAY --border --help --input

		# EXIT PROGRAM
		exitProgram
	}


	# MENU CALLBACK
	function callback() {

		if [ "$1" ]; then

			GUI INIT
			local text="PRESS ANY KEY TO CONTINUE"
			setTextAlign "${text}"
			echo -en $(color black "[ ")
			echo -en $(color white "${text}")
			echo -en $(color black " ]")
			read -sN1

			clear
		fi
	}

	init
