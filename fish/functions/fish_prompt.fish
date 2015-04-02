function prompt_arrow_close --argument-name BG FG END -d "close the previous fishline segment"
	set FLSYM_PRE_CLOSE " "
	set FLSYM_CLOSE "\uE0B0"
	set FLSYM_POST_CLOSE " "

	if set -q FLINT_BCOLOR
		printf "$FLSYM_PRE_CLOSE"
		set_color -b $BG
		set_color "$FLINT_BCOLOR"
		printf $FLSYM_CLOSE
		set_color normal
	end
	
	set_color -b $BG $FG
	if [ "$END" != True ]
		printf "$FLSYM_POST_CLOSE"
	end
	set -g FLINT_BCOLOR $BG
end

function fish_prompt --description 'Write out the prompt'

	set -l last_status $status
	set -l uid (id -u $USER)

	set -l sudo_char \u2622

	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end

	# sudo
	if [ $uid -eq 0 ]
		prompt_arrow_close yellow black
		echo -n $sudo_char
	end

	# PWD
	set bg_color cyan
	if not test $last_status -eq 0
		set bg_color magenta
	end

	prompt_arrow_close $bg_color black
	echo -n (basename (echo $PWD | sed -e "s|^$HOME|~|"))

	prompt_arrow_close normal normal True
	set -e FLINT_BCOLOR

	echo -n ' '
end
