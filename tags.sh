#!/bin/bash
# Read in the ~/.projects file which contains on each line one directory in
# which to create project tags and ID files.

#ctags_exe="c:\documents and settings\tbrown\my documents\bin\ctags.exe"
tags_file="/Volumes/UserBackup/TBrown/work/workspace/tags"
id_file="/Volumes/UserBackup/TBrown/work/workspace/ID"
source_files="/Volumes/UserBackup/TBrown/work/workspace"

if [ ! -e ~/.projects ]; then
	echo "No ~/.projects file. No databases to update"
	exit
fi

for directory in `cat ~/.projects`; do
	echo "Creating databases for ${directory}"
	ctags -f "${directory}/tags" -R --extra=+fq --fields=+afiksSt ${directory}
	mkid -p .svn -p CVS -o ${directory}/ID ${directory} 
done

