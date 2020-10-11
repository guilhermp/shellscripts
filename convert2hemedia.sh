#!/bin/zsh
# Converts old media to high efficiency formats to save disk space
# dependencies: sips, ffmpeg

newfolder="HE Media"
oldfolder="Old Media"
mkdir "$newfolder"
mkdir "$oldfolder"

setopt null_glob
for origfile in *.{MOV,MP4,JPG,JPEG,mov,mp4,jpg,jpeg} ; do
	origext="${origfile##*.}"
	origname="${origfile%.*}"
	case "$origext" in
		MOV|mov|MP4|mp4)
			# Set new extension
			newext="MOV"
			
	    	# Convert old video to the new HEVC format
			ffmpeg -i "$origfile" -c:v libx265 -crf 23 -c:a aac -b:a 128k -tag:v hvc1 -vf "colormatrix=bt470bg:bt709" -map_metadata 0 -movflags use_metadata_tags -f MOV "$newfolder/$origname.$newext"			

			# Preserve file creation date
			touch -r "$origfile" "$newfolder/$origname.$newext"
			
			# Cleanup old file
			mv "$origfile" "$oldfolder/"
	    	;;
		JPG|jpg|JPEG|jpeg)
			# Set new extension
			newext="HEIC"
			
			# Convert old photo to the new HEVC format
			sips -s format heic $origfile --out "$newfolder/$origname.$newext"
			
			# Preserve file creation date
			#exiftool -TagsFromFile "$origfile" "-all:all>all:all" "$newfolder/$origname.$newext"
			touch -r "$origfile" "$newfolder/$origname.$newext"
			
			# Cleanup old file
			mv "$origfile" "$oldfolder/"
			#rm $newfolder/*_original
    		;;
	  	*)
	    	echo "Unsupported format!"
	    	;;
	esac
done

diff <(du -sh $oldfolder) <(du -sh $newfolder)

echo "Done! Check new media at $newfolder/."


echo "Delete old media? [y/N]: "
if read -q; then
    echo "Removing $oldfolder..."
	rm -rf $oldfolder

    echo "Moving new files to the current directory..."
	mv $newfolder/* .
	rm -rf $newfolder/
else
  echo "Alright!"
fi

echo "Old media deleted."
# ask if ok to delete old media