#puppet13th
#diff.exe --binary --text --normal --minimal file1.7z file2.7z > patch2
#patch.exe --normal --binary file1.7z -o file1-new.7z -i patch2 --dry-run

#full filename structure = originaldate-filename.extension
#patch filename structure = originaldate-filename-patchdate.patch

datafile=data.7z
source_folder=01source
target_folder=02target
backup_folder=03backup
patch_max_num=6

source=$source_folder/$datafile
target=$target_folder/$datafile
target_temp=$target_folder/$datafile-temp

todaydate=`date +%Y%m%d%H%M`

diff=diff.exe
patch=patch.exe
md5sum=md5sum
null=nul

#check if source data exist
if [ ! -f "$source" ]
	then
	echo source data file "$source" not exist ! ! !
	exit 0
fi

#check if target data exist,if not copy source data to target data
if [ ! -f "$target" ]
	then
	echo creating base data . . .
	cp "$source" "$target"
	cp "$target" "$target_folder"/$todaydate-"$datafile"
	exit 0
fi 

#define target0
if [ -f "$target_folder"/*-"$datafile" ]
	then
	target0="$target_folder"/*-"$datafile"
	else
	cp "$target" "$target_folder"/$todaydate-"$datafile"
	target0="$target_folder"/$todaydate-"$datafile"
fi

#check number of patch
patch=0
for file in "$target_folder"/*-"$datafile"-*.patch
	do
	if [ -f "$file" ]
		then
		patch=`expr $patch + 1`
	fi
done
if [ $patch_max_num -eq $patch ]
	then
	echo moving target data to "$backup_folder"
	mv `eval echo "$target0"` "$backup_folder"/
	for file in "$target_folder"/*-"$datafile"-*.patch
	do
		mv "$file" "$backup_folder"/
	done
	for file in "$target_folder"/*-"$datafile"-*.patch.md5
	do
		mv "$file" "$backup_folder"/
	done
	mv "$target" "$target_folder"/$todaydate-"$datafile"
	target0="$target_folder"/$todaydate-"$datafile"
	cp "$target0" "$target"
fi

#check if source data and target data are different
$diff "$target" "$source" > $null
if [ $? -ne 0 ]
	then
	patchfile=`eval echo "$target0"`-$todaydate.patch
	diff.exe --binary --text --normal --minimal "$target" "$source" > "$patchfile"
	#test patch file
	patch.exe --normal --binary "$target" -i "$patchfile" --dry-run
	if [ $? -eq 0 ]
		then
		echo verifying "$patchfile"...
		patch.exe --normal --binary "$target" -i "$patchfile" -o "$target_temp"
		if [ $? -eq 0 ]
			then
			$diff "$source" "$target_temp" > $null
			if [ $? -eq 0 ]
				then
				echo "$patchfile" verified...
				echo creaing md5...
				$md5sum "$patchfile" > "$patchfile".md5
				rm -f "$target_temp"
				echo patching "$target"...
				patch.exe --normal --binary "$target" -i "$patchfile"
				else
				echo "$patchfile" verify failed...
				rm -f "$patchfile"
				exit 1
			fi
			else
			echo "$patchfile" verify failed...
			rm -f "$patchfile"
			exit 1
		fi
		else
		echo "$patchfile" verify failed...
		rm -f "$patchfile"
		exit 1
	fi
	else
	echo no data update!
	exit 0
fi