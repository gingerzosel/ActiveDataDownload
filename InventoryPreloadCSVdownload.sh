#!/bin/bash
####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
#
####################################################################################################
# This script will download all active data for Inventory Preload items within the Jamf Pro server
#
#
#
####################################################################################################
#
# READ IN PARAMETERS (NO NEED TO CHANGE ANYTHING HERE)
#
####################################################################################################
# 2021 Ginger Zosel


date=$(date +"%m-%d-%T")
outputfile="/tmp/ActiveData-$date.csv"

read -p "Jamf Pro Server URL:  " server
read -p "Jamf Pro Username: " username
read -s -p "Jamf Pro Password: " password

echo ""
####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

encodedCredentials=$( printf "$username:$password" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

# generate an auth token
authToken=$( /usr/bin/curl "$server/uapi/auth/tokens" \
--silent \
--request POST \
--header "Authorization: Basic $encodedCredentials" )

# parse authToken for token, omit expiration
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$authToken" | /usr/bin/xargs )

# Trim the trailing slash off the server url if necessary courtesy of github dot com slash iMatthewCM
if [ $(echo "${server: -1}") == "/" ]; then
	server=$(echo $server | sed 's/.$//')
fi

#Engage the JPAPI!
echo "Downloading CSV"
echo "CSV will be saved to /tmp in a file named Active Data with the date and time"
curl -s -H "accept: application/json" -H "Authorization: Bearer $token" "$server/api/v2/inventory-preload/csv" -o $outputfile
echo "File Download Complete"

