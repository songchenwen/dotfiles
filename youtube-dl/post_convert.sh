filename=$( basename "$1" )
extension="${filename##*.}"
filename="${filename%.*}"
dirname=$( dirname "$1" )

result=$1
if [[ "$extension" == "flv" ]]; then
	out="$dirname/$filename.mkv"
	ffmpeg -i "$1" -c copy "$out"
	if [[ $? == 0 ]]; then
		rm "$1"
		result=$out
	fi
fi
tag -a "未完" "$result"
