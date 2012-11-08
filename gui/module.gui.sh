#!/bin/bash

	# AN API FOR MAKING "GUI" MENUES IN BASH SCRIPT - EASY AND NEAT.
	# - Filip Moberg

	
	# THE GUI "CLASS" SCOPE
	function GUI() {

		local ARGS=()
		local INDEX=0


		# BUILD ARGUMENT ARRAY
		for key in "$@"; do
			
			if [ $INDEX -gt 0 ]; then
				ARGS[$INDEX]="$key"
			fi

			INDEX=$(($INDEX+1))
		done


		function OUTPUT() {

			if [ "$1" == "--headline" ]; then

				push HEADLINE "$2"
			else
				push OUTPUT "$1"
			fi
		}


		function DISPLAY() {

			local border=false
			local navigation=false
			local help=false

			_GUI_DISPLAY_ARGS=($@)


			if [ ${#OUTPUT[@]} -eq 0 ]; then

				_GUI_DISPLAY_ARGS=(${_GUI_DISPLAY_PREVIOUS_ARGS[@]})
				clone PREVIOUS_OUTPUT OUTPUT
				clone PREVIOUS_HEADLINE HEADLINE
			else
				clear
			fi

			for key in "${_GUI_DISPLAY_ARGS[@]}"; do

				if [ "$key" == "--border" ]; then
					border=true
				fi

				if [ "$key" == "--navigation" ]; then

					navigation=true
				fi

				if [ "$key" == "--input" ]; then

					input=true
				fi

				if [ "$key" == "--help" ]; then
					help=true
				fi
			done

			unset MERGE

			clone --merge HEADLINE MERGE
			clone --merge OUTPUT MERGE

			local x=$(arrayAlignX MERGE)
			local y=$(arrayAlignY MERGE)

			if [ "$navigation" == true ]; then

				_GUI_NAVIGATION=true
			fi

			if [ "$_GUI_NAVIGATION" == true ]; then
				
				x=$(($x-2))
			fi

			if [ "$help" ]; then

				GUI HELP
			fi


			# ADD HEADLINE IF APPLICABLE
			if [ "$HEADLINE" ]; then

				if [ "$border" == true ]; then

					y=$(($y-2))
				else
					y=$(($y-1))
				fi

				for key in "${!HEADLINE[@]}"; do

					tput cup $y $x
					y=$(($y+1))

					echo -en "${HEADLINE[$key]}"
				done

				if [ "$border" == true ]; then

					y=$(($y+1))
				fi
			fi


			# ADD BORDER IF APPLICABLE
			if [ "$border" == true -a "$navigation" == true ]; then

				GUI BORDERS $x $y
			fi

			# ADD BORDER IF APPLICABLE
			if [ "$border" == true -a "$input" == true ]; then

				GUI BORDERS $x $y
			fi


			# ADD CONTENT IF APPLICABLE
			for key in "${!OUTPUT[@]}"; do

				y=$(($y+1))
				tput cup $y $x

				if [ "$_GUI_NAVIGATION" ]; then

					if [ $_GUI_NAVIGATION_ITEM_SELECTOR -eq $key ]; then
						echo -en $(color black)
						echo -en "⇢  "
						echo -en $(color)
					else
						echo -en "  "
					fi
				fi

				LAST_OUTPUT=${OUTPUT[$key]}

				echo -en $LAST_OUTPUT
				echo -en "   "
			done


			# STORE OUTPUT
			_GUI_DISPLAY_PREVIOUS_ARGS=$_GUI_DISPLAY_ARGS
			unset _GUI_DISPLAY_PREVIOUS_ARGS

			for key in "${_GUI_DISPLAY_ARGS[@]}"; do

				if [ "$key" != "--navigation" ]; then
					push _GUI_DISPLAY_PREVIOUS_ARGS "$key"
				fi
			done

			clone OUTPUT PREVIOUS_OUTPUT
			clone HEADLINE PREVIOUS_HEADLINE

			# CLEAR OUTPUT BUFFERS
			unset HEADLINE
			unset OUTPUT

			# ACTIVATE NAVIGATION
			if [ "$navigation" == true ]; then

				GUI NAVIGATION --init
			fi

			# ACTIVATE INPUT
			if [ "$input" == true ]; then

				GUI INPUT --init
			fi

		}


		function INPUT() {


			for key in "$@"; do

				if [ "$key" == "--init" ]; then
					state="init"
				fi

				if [ "$key" == "--callback" ]; then
					state="callback"
				fi
			done

			if [ "$state" == "init" ]; then

				INPUT_WIDTH=$(textTrimColor "${LAST_OUTPUT}")
				INPUT_WIDTH=${#INPUT_WIDTH}

				tput cup $y $(($x+$INPUT_WIDTH))

				stty echo
				tput cnorm

				read _INPUT

				GUI INIT

				clear

				$_GUI_INPUT_CALLBACK $_INPUT
			fi

			if [ "$state" == "callback" ]; then

				_GUI_INPUT_CALLBACK="$2"

				return
			fi
		}


		function NAVIGATION() {

			local state=""

			if [ -z $_GUI_NAVIGATION_ITEM_SELECTOR ]; then
				_GUI_NAVIGATION_ITEM_SELECTOR=0
			fi
			
			for key in $@; do

				if [ "$key" == "--item" ]; then
					state="item"
				fi

				if [ "$key" == "--init" ]; then
					state="init"
				fi

				if [ "$key" == "--input" ]; then
					state="input"
				fi

				if [ "$key" == "--keyUp" ]; then
					state="keyUp"
				fi

				if [ "$key" == "--keyDown" ]; then
					state="keyDown"
				fi

				if [ "$key" == "--keyQ" ]; then
					state="keyQ"
				fi

				if [ "$key" == "--keyE" ]; then
					state="keyE"
				fi
			done

			if [ "$state" == "item" ]; then

				push _GUI_NAVIGATION_ITEMS "$2"
				return
			fi 

			if [ "$state" == "init" ]; then

				_GUI_NAVIGATION=true
				while true; do

					read -sN1 _GUI_NAVIGATION_INPUT
					case "${_GUI_NAVIGATION_INPUT}" in

						w) GUI NAVIGATION --keyUp;;
						s) GUI NAVIGATION --keyDown;;
						q) GUI NAVIGATION --keyQ; break;;
						"" | e) GUI NAVIGATION --keyE; break;;
					esac
				done

				return
			fi 
			
			if [ "$state" == "keyUp" ]; then

				if [ $_GUI_NAVIGATION_ITEM_SELECTOR -gt 0 ]; then

					_GUI_NAVIGATION_ITEM_SELECTOR=$((_GUI_NAVIGATION_ITEM_SELECTOR-1))
					GUI DISPLAY
				fi

				return
			fi
			
			if [ "$state" == "keyDown" ]; then

				if [ $_GUI_NAVIGATION_ITEM_SELECTOR -lt $(($(length _GUI_NAVIGATION_ITEMS)-1)) ]; then

					_GUI_NAVIGATION_ITEM_SELECTOR=$((_GUI_NAVIGATION_ITEM_SELECTOR+1))
					GUI DISPLAY
				fi

				return
			fi
			
			if [ "$state" == "keyQ" ]; then

				clear

				GUI EXIT

				return
			fi

			if [ "$state" == "keyE" ]; then

				local command="${_GUI_NAVIGATION_ITEMS[$_GUI_NAVIGATION_ITEM_SELECTOR]}"

				unset _GUI_NAVIGATION
				unset _GUI_NAVIGATION_ITEMS
				unset _GUI_NAVIGATION_ITEM_SELECTOR
				unset _GUI_DISPLAY_PREVIOUS_ARGS
				unset _GUI_DISPLAY_PREVIOUS_OUTPUT
				unset _GUI_DISPLAY_PREVIOUS_HEADLINE

				$command

				return
			fi

		}

		function BORDERS() {

			local width=$(($(arrayWidth MERGE)+6))
			local height=$(($(length MERGE)+3))
			local x=$((${1}-3))
			local y=$((${2}-1))
			local lineTop=""
			local lineMiddle=""
			local lineBottom=""

			local charTopCornerLeft="┏"
			local charTop="━"
			local charTopCornerRight="┓"
			local charMiddleCornerRight="┫"
			local charMiddle="━"
			local charMiddleCornerLeft="┣"
			local charBottomCornerRight="┛"
			local charBottom="━"
			local charBottomCornerLeft="┗"
			local charRight="┃"
			local charLeft="┃"

			
			echo -en $(color black)

			for ((i=0; i < $width; i++)); do

				if [ "$i" == 0 ]; then
					lineTop+="$charTopCornerLeft"
					lineMiddle+="$charMiddleCornerLeft"
					lineBottom+="$charBottomCornerLeft"
				elif [ "$i" == $(($width-1)) ]; then
					lineTop+="$charTopCornerRight"
					lineMiddle+="$charMiddleCornerRight"
					lineBottom+="$charBottomCornerRight"
				else 
					lineTop+="$charTop"
					lineMiddle+="$charMiddle"
					lineBottom+="$charBottom"
				fi
			done


			if [ ${#HEADLINE} -gt 0 ]; then

				tput cup $(($y-1)) $(($x+0))
	#			echo $charLeft

				tput cup $(($y-1)) $(($x+$width-1))
	#			echo $charRight

				tput cup $(($y-2)) $x
				echo $lineTop

				lineTop="${lineMiddle}"
			fi


			for ((i=0; i < $height; i++)); do

				tput cup $y $x

				if [ "$i" == 0 ]; then

					echo -en "$lineTop"

				elif [ "$i" == $(($height-1)) ]; then

					echo -en "$lineBottom"

				else

	#				echo -en "$charLeft"
					tput cup $y $(($x+$width-1))
	#				echo -en "$charRight"
				fi

				y=$(($y+1))
			done

			echo -en $(color)
		}


		function HELP() {

			local x=4
			local y=$(($(tput lines)-2))

			tput cup $y $x
			echo -en $(color black "[ NAVIGATION KEYS ]  w: ⇡  s: ⇣  e: [enter]  q: [exit]")
		}

		function INIT() {

			stty -echo
			tput civis
		}

		function EXIT() {

			stty echo
			tput cnorm
			exit
		}

		# RUN SUB FUNCTION AND PASS ALONG THE ARGUMENTS
		$1 "${ARGS[@]}"
	}
