#!/bin/bash
#ctags_exe="c:\documents and settings\tbrown\my documents\bin\ctags.exe"
tags_file="${HOME}/.tags"

case `uname` in
	Linux*)
		directories="/usr/include /usr/local/include"
		;;
	Darwin*)
		directories="/usr/include /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/"
		;;
	*)
		echo "Unknown system. Using defaults."
		directories="/usr/include"
esac

ctags -u -V -f ${tags_file} -R --extra=+fq --fields=+afiksSt $directories


