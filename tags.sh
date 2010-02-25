#!/bin/bash
#ctags_exe="c:\documents and settings\tbrown\my documents\bin\ctags.exe"
tags_file="/Volumes/UserBackup/TBrown/work/workspace/tags"
id_file="/Volumes/UserBackup/TBrown/work/workspace/ID"
source_files="/Volumes/UserBackup/TBrown/work/workspace"

ctags -f ${tags_file} -R --extra=+fq --fields=+afiksSt ${source_files}

mkid -p .svn -p CVS -o ${id_file} ${source_files} 

