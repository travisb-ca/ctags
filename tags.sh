#!/bin/bash
#ctags_exe="c:\documents and settings\tbrown\my documents\bin\ctags.exe"
tags_file="${HOME}/workspace/tags"
source_files="${HOME}/workspace"

ctags -V -f ${tags_file} -R --extra=+fq --fields=+afiksSt /usr/include ${source_files}


