#!/bin/bash
if [ "$#" -ne 0 ]; then
	file=$1;
	if [ -f "$file" ]; then
		filename=${file##*/};
		guard=$(echo __$(echo ${filename^^} | tr . _)__ );
		echo -e "\`ifndef $guard\n\`define $guard\n$(cat $file)\n\`endif" > $file;
	else
		echo "NOT A FILE"
	fi
else
	echo "Apply Guard to All Files in Directory? [y/N]"
	read yes
	if [ "$yes" = "y" ]; then
		for file in *.v; do
			filename=${file##*/};
			guard=$(echo __$(echo ${filename^^} | tr . _)__ );
			echo -e "\`ifndef $guard\n\`define $guard\n$(cat $file)\n\`endif" > $file;
		done
	fi
fi
