function aria2_from_clipboard
	set commands (pbpaste)
	set count 0
	for command in $commands
		if echo "$command" | grep -q -E '^aria2c .*'
			set count (expr $count + 1)
		end
	end
	if test $count -gt 0
		set cdir $PWD
		cd ~/Downloads
		for command in $commands
			if echo "$command" | grep -q -E '^aria2c .*'
				echo $command
				eval $command
			end
		end
		cd $cdir
	else
		echo No aria2 command found
	end
end