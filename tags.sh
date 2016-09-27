#!/bin/bash
# Read in the ~/.projects file which contains on each line one directory in
# which to create project tags and ID files.
#
# Any additional relative directories on that line are directories inside the
# names directory which will not be indexed. eg.
#
# /home/travis/projects/foo annoying_directory a/r/s/t/listings

# Macros to ignore with ctags
ctags_ignore_macros="-I EXPORT_SYMBOL,EXPORT_SYMBOL_GPL"

# First arg is the directory to process.
# Any other args are subdrectories to skip
function process {
        directory=$1
        shift
        exclusions=$@

        if [ -d ${directory} ]; then
           echo "Creating databases for ${directory}"
        else
           echo "Skipping databases for ${directory}"
           return
        fi
        suffix=".new"
	ctags_exclude="-name .git -prune -o "
	ctags_exclude+="-name .repo -prune -o "
	ctags_exclude+="-name .pc -prune -o "

	mkid_exclude="--prune ${directory}/.svn "
	mkid_exclude+="--prune ${directory}/CVS "
	mkid_exclude+="--prune ${directory}/.git "
	mkid_exclude+="--prune ${directory}/.repo "
	mkid_exclude+="--prune ${directory}/.pc "

	for dir in $exclusions; do
		ctags_exclude="${ctags_exclude} -path ${directory}/${dir} -prune -o"
		mkid_exclude="${mkid_exclude} --prune=${directory}/${dir}"
	done

	ctags_exclude+=" ! -path ${directory}/tags -a "
	ctags_exclude+="! -path ${directory}/tags.new -a "

        # If we don't have any tags build them inplace to be useful as soon as
        # possible
        if [ ! -e "${directory}/tags" -a ! -e "${directory}/ID" ]; then
            suffix=""
        fi

        find "${directory}" ${ctags_exclude} -type f -print | ctags --filter=yes --sort=no ${ctags_ignore_macros} -R --extra=+fq --fields=+afiksSt > "${directory}/tags${suffix}" &

        CTAGS=$!
        
	mkid --lang-map=${HOME}/bin/id-lang.map -x 'lisp asm' ${mkid_exclude} -o ${directory}/ID${suffix} ${directory} 2> /dev/null &

        wait $CTAGS

        LC_ALL=C sort -o "${directory}/tags${suffix}" "${directory}/tags${suffix}"
        
        if [ -f "${directory}/tags${suffix}" ]; then
                python - "${directory}/tags${suffix}" "${directory}/tags.tmp" <<END
#!/usr/bin/env python
# After the tags file has been sorted resort each tag based on the kind
#
# Usage: kindsort.py infile outfile

import sys

kind_priority = 'cstgfmuvF' # anything not in this list will sort last

def extract_key(line):
	if line[0] == '!':
		return 0

	kind = line.split(';"\t')[1][0]
	try:
		index = kind_priority.index(kind)
	except:
		index = len(kind_priority)

	return index

infile = open(sys.argv[1], 'r')
outfile = open(sys.argv[2], 'w')

outfile.write('''!_TAG_FILE_FORMAT	2	/extended format; --format=1 will not append ;" to lines/
!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted, 2=foldcase/
!_TAG_PROGRAM_AUTHOR	Darren Hiebert	/dhiebert@users.sourceforge.net/
!_TAG_PROGRAM_NAME	Exuberant Ctags	//
!_TAG_PROGRAM_URL	http://ctags.sourceforge.net	/official site/
!_TAG_PROGRAM_VERSION	5.8	//''')

lines_to_sort = []
current_tag = ''

for line in infile:
	tag = line.split('\t', 1)[0]

	if tag != current_tag:
		# We've moved onto a new tag, so sort what we've got and start
		# again
		lines_to_sort.sort(key=extract_key)
		outfile.write(''.join(lines_to_sort))

		lines_to_sort = []
		current_tag = tag

	lines_to_sort.append(line)

lines_to_sort.sort(key=extract_key)
outfile.write('\n'.join(lines_to_sort))
END

            if [ "$?" -eq 0 ]; then
               mv "${directory}/tags.tmp" "${directory}/tags${suffix}"
            else
               echo "Error resorting tags file"
               exit
            fi
        fi

        wait # wait for mkid

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
