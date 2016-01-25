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

        find "${directory}" -type f | ctags --filter=yes --sort=no ${ctags_ignore_macros} --exclude=.git --exclude=.repo --exclude=.pc ${ctags_exclude} -R --extra=+fq --fields=+afiksSt > "${directory}/tags${suffix}" &
        
	mkid --lang-map=${HOME}/bin/id-lang.map -p ${directory}/.svn -p ${directory}/CVS -p ${directory}/.git -p ${directory}/.repo -p ${directory}/.pc -x lisp ${mkid_exclude} -o ${directory}/ID${suffix} ${directory} 2> /dev/null &

        wait %1 # wait for ctags
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

            mv "${directory}/tags.tmp" "${directory}/tags${suffix}"
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
