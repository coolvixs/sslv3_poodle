#!/bin/bash
#
#  Copyright (C) 2014 by Dan Varga
#  dvarga@redhat.com
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.

# The following was added by Vikash Gounder 2014
# coolvixs@gmail.com
# Added the following change
# - Add the option to test multiple domains
# - read a file which can be passed as a parameter
# - and output the result

file=$1
port=$2

if [ "$2" == "" ]
then
	port=443
fi

while read host; do
	out="`echo x | timeout 5 openssl s_client -ssl3 -connect ${host}:${port} 2>/dev/null`"
	ret=$?

	if [ $ret -eq 0 ]
	then
		echo "VULNERABLE! SSLv3 detected."
		exit
	elif [ $ret -eq 1 ]
	then
		out=`echo $out | perl -pe 's|.*Cipher is (.*?) .*|$host|'`
		if [ "$out" == "0000" ] || [ "$out" == "(NONE)" ]
		then
			echo "Not Vulnerable. We detected that this server does not support SSLv3"
			exit
		fi
	elif [ $ret -eq 124 ]
	then
		echo "error: timeout connecting to host $host:$port"
		exit
	fi
	echo "error: Unable to connect to host $host:$port"

done < $1


