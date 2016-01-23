#!/bin/sh

# bwt3.sh: Extract border wait time data from key-value pairs using lynx, sed and tr.
#
# Tested on Ubuntu 14.04.3 LTS. (BKH 2016-01-22)
#
# Schedule to run once an hour, at half past the hour, e.g.:
#     $ echo '30 * * * * ~/bin/bwt3.sh' | crontab

URL='http://apps.cbp.gov/bwt/portList.asp?action=port&n=250401'
CSV=data/sy3.csv

# Create data folder
mkdir -p data

# Output one line of data with a timestamp.
lynx -dump "$URL" | \
    sed -n -e 's/, /;/g' -e 's/^[ ]\{7\}[A-Z].*: //p' | tr "\n" "," | \
    xargs echo $(date +"%Y-%m-%d %H:%M:%S,") >> "$CSV"
