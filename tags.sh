#!/bin/bash
# Read in the ~/.projects file which contains on each line one directory in
# which to create project tags and ID files.
#
# Any additional relative directories on that line are directories inside the
# names directory which will not be indexed. eg.
#
# /home/travis/projects/foo annoying_directory a/r/s/t/listings

#ctags_exe="c:\documents and settings\tbrown\my documents\bin\ctags.exe"
tags_file="/Volumes/UserBackup/TBrown/work/workspace/tags"
id_file="/Volumes/UserBackup/TBrown/work/workspace/ID"
source_files="/Volumes/UserBackup/TBrown/work/workspace"

# Macros to ignore with ctags
ctags_ignore_macros="-I EXPORT_SYMBOL,EXPORT_SYMBOL_GPL"

# First arg is the directory to process.
# Any other args are subdrectories to skip
function process {
        directory=$1
        shift
        exclusions=$@

	echo "Creating databases for ${directory}"
        suffix=".new"
	ctags_exclude=""
	mkid_exclude=""
	for dir in $exclusions; do
		ctags_exclude="${ctags_exclude} --exclude=${directory}/${dir}"
		mkid_exclude="${mkid_exclude} --prune=${directory}/${dir}"
	done

        # If we don't have any tags build them inplace to be useful as soon as
        # possible
        if [ ! -e "${directory}/tags" -a ! -e "${directory}/ID" ]; then
            suffix=""
        fi

	ctags -f "${directory}/tags${suffix}" ${ctags_ignore_macros} --exclude=.git --exclude=.repo --exclude=.pc ${ctags_exclude} -R --extra=+fq --fields=+afiksSt ${directory} &
        
	mkid --lang-map=${HOME}/bin/id-lang.map -p ${directory}/.svn -p ${directory}/CVS -p ${directory}/.git -p ${directory}/.repo -p ${directory}/.pc -x lisp ${mkid_exclude} -o ${directory}/ID${suffix} ${directory} 2> /dev/null &

        wait
        if [ -n "$suffix" ]; then
            mv "${directory}/tags${suffix}" "${directory}/tags"
            mv "${directory}/ID${suffix}" "${directory}/ID"
        fi

}

if [ -z "$1" ]; then
    # Process the projects
    
    if [ ! -e ~/.projects ]; then
            echo "No ~/.projects file. No databases to update"
            exit
    fi

    while read directory exclusions; do
        process $directory $exclusions
    done < ~/.projects
else
    # Process only the immediate arguments
    process $@
fi
