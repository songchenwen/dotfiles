function captureScreen
	set DATE (date +"%Y-%m-%d-%H-%M-%S")
	mkdir -p ~/Desktop/ScreenCap
	adb shell screencap -p | perl -pe "s/\x0D\x0A/\x0A/g" > ~/Desktop/ScreenCap/Screen_$DATE.png
end