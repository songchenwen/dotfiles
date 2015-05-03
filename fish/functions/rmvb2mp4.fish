function rmvb2mp4 --argument-name INPUT -d "Convert RMVB to MP4 by ffmpeg"
	if echo "$INPUT" | grep -q -E '.*\.rmvb$'

		set -l OUTPUT (echo $INPUT | sed 's/rmvb$/mkv/g')
		
		echo "Convert $INPUT to $OUTPUT"
		
		ffmpeg -loglevel error -i $INPUT -c:v libx264 -preset veryfast -crf 18 -c:a copy $OUTPUT

	else
		set_color red
		echo "Need an RMVB file as input"
		set_color normal
		return 1
	end
end
