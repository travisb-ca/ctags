rem @echo off
set ctags_exe="c:\documents and settings\tbrown\my documents\bin\ctags.exe"
set tags_file="c:\workspace\tags"
set source_files="c:\workspace"

%ctags_exe% -V -f %tags_file% -R --extra=+fq --fields=+afiksSt "%VS80COMNTOOLS%..\..\VC" %source_files%


