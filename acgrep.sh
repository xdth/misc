#!/bin/bash

######################### acgrep.sh v0.1 ###############################
# This script will grep a given set of strings from a text file (syslog)
# and output the result, excluding lines containing  another set of 
# strings, to a specified location, with a dated file name.
#
# The script will then delete all files in the destination folder older
# than X days and change the ownership of the resulting files to the
# web server.
#
# It can be used, for example, to generate logs from AssaultCube or
# UrbanTerror servers, one log per server.
#
# author: dth@dthlabs.com
#
# To run dayly, add to your cron: 
# 0 */1 * * * /root/aclogs/acgrep.sh

# #######################################################################
# ## Parameters

# The file to grep
acgrep_filePath="/var/log/syslog"

# Location where the files will be generated. Keep the trailing slash.
acgrep_destinationPath="/root/aclogs/"

# grep this string
acgrep_string="AssaultCube"

# The AC servers' ports
acgrep_substrings="28763 8000 9000 10000 16000"

# Delete generate files after this amount of days
acgrep_keep_days=7

# Regex to skip lines containing these strings
acgrep_skipline="/xskip\|pwd/d"

# #######################################################################
# ## Functions

function acgrep_init {
  # feed $YESTERDAY with the syslog format "Jan 31"
  YESTERDAY=$(date -d "yesterday 06:00" '+%b %d')
  # feed $YESTERDAY2 with yesterday's date in the format 2018-01-31
  YESTERDAY2=$(date -d "yesterday 06:00" '+%Y-%m-%d')
}

function acgrep_finish {
  # Make destination folder readable to the web server
  chown www-data:www-data -R "$acgrep_destinationPath"

  # Delete file older than x days
  /usr/bin/find "$acgrep_destinationPath" -mtime +$acgrep_keep_days -type f -delete
}

function acgrep_main {
  # initialize date variables
  acgrep_init

  # main loop
  for i in $acgrep_substrings
  do
  # cat /var/log/syslog | grep "AssaultCube" | grep "$YESTERDAY" | grep 8000 > /home/dth/8000_2018-01-31.txt
    sed $acgrep_skipline $acgrep_filePath | grep $acgrep_string | grep "$YESTERDAY" | grep $i > "$acgrep_destinationPath"$i"_"$YESTERDAY2.txt
  done

  # clean up and finish
  acgrep_finish
}


# Execute
acgrep_main
