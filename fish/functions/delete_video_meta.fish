function delete_video_meta --argument-name INPUT -d "Delete Metadata of a Video File"
	set -l OUTPUT (printf '%s/NewWithoutMeta%s' (dirname $INPUT) (basename $INPUT))
	ffmpeg -loglevel error -i $INPUT -c copy -map_metadata -1 $OUTPUT
	if test $status -eq 0
		rm $INPUT
		mv $OUTPUT $INPUT
	end
end
