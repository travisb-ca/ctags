#!/bin/bash
#ctags_exe="c:\documents and settings\tbrown\my documents\bin\ctags.exe"
tags_file="${HOME}/workspace/tags"
id_file="${HOME}/workspace/ID"
source_files="${HOME}/workspace"

ctags -f ${tags_file} -R --extra=+fq --fields=+afiksSt ${source_files}

mkid -p .svn -p CVS -o ${id_file} ${source_files} 

