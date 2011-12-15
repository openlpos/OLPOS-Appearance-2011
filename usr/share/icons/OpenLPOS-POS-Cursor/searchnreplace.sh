#!/bin/bash

# ---- Filename: sr
#
# Nihar S. Khedekar, 15.Jul.2004 NCST, Bangalore
# 
# 
# Script to search for a particular regular expression
# in multiple files and replace it with another expression.
# 
# Such a situation simply demands the use of `sed'
# So obviously we are going to use it ;-)
# 
 
#  The program accepts three arguments.
#  
#  1. The Regular expression that has to be used to search for the pattern
#      This has to be a `sed' compatible expression.
#  2. A replace string. Again it can be `sed' compatible. So you are
#      free to use all those things that the `substitute' command of `sed'
# 	 permits.
#  3. The search string to look out for a file name. Now this one has to
#      be the `ls' type search string. It will be used with `find -name' so
# 	   you know exactly what syntax we support. 
#     This is an optional parameter.. if you dont specify anything. All files
#     would be searched for.
# 
# 

if test $# -lt 1
then echo "Usage: `basename $0` srch-string [replace-string [file-srch-string]]
     search-string: \`sed' compatible regular expression, 
                    that has to be searched for
    replace-string: \`sed' compatible replace string
  file-srch-string: \`find' compatible search expression
                    to search for files to operate on.

Version 1.02
(c) CDAC, Electronics City, Bangalore.
This program comes with ABSOLUTELY NO WARRANTY.
Use it at YOUR OWN RISK.

Feel free to send bugs, feedback or suggestions to,
nihar [at] ncb [dot] ernet [dot] in
"
	 exit;
fi

# Handle SIGINT. Ctrl+C
trap_sigint() {
	echo -e "\nOuch! That was painful... Am dead!"
	exit 
}

trap trap_sigint SIGINT

strSearch="$1"
strReplace="$2"

if test "$strSearch"a = a
then echo Dont wanna search anything do you?
	 exit
fi

if test "$3"a = a # No filename search mentioned!
then echo "All files selected."
	 strFindFlag=
else strFindFlag="-name"
fi

# Create a temporary file for saving what sed wil give:
strTempFileName="/tmp/sr`date +%s`"
if test -f "$strTempFileName"
then strTempFileName="$strTempFileName$strTempFileName"
fi

bYesForAll=false;
bSkipFile=false;

for strEachFoundFile in `find -type f $strFindFlag $3`
do
	if ! $bYesForAll 
	then 
		while true; 
		do
		 read -n1 -p"Replace \`$strSearch' with \`$strReplace' in $strEachFoundFile? [yES/nO/aLL/qUIT/?] " answer
		 case $answer in 
			 "A"|"a") echo -e "\bYes to all."; bYesForAll=true;
					  echo -n "Processing \`$strEachFoundFile'... "
					  break;;
			 "N"|"n") echo -e "\b$strEachFoundFile skipped."; 
			 		  bSkipFile=true;
			 		  break;;
			 "Q"|"q") echo -e "\bQuiting.."; exit;;
			 "Y"|"y") echo -en "\b \b"; break;;
			 *) echo -e "\bPLEASE SELECT EITHER OF [y/n/a/q/?]
   y: Yes; Perform the operation on \`$strEachFoundFile'
   n: No; Skip to the next file.
   a: All; Yes to all. 
   q: Quit; Quit the complete program."; 
   				continue;;
		  esac
		done
	else 
	   echo -n "Processing \`$strEachFoundFile'... ";
	fi

	if $bSkipFile; then bSkipFile=false; continue; fi
	sed -e "s/$strSearch/$strReplace/g" "$strEachFoundFile" > "$strTempFileName"
	if /bin/cp -f "$strTempFileName" "$strEachFoundFile"
	then echo "done."
	fi
done

rm -f "$strTempFileName"

