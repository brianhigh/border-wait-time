#!/bin/sh

# bwt.sh: Extract border wait time data from HTML using sed and tr.
#
# Tested on Ubuntu 14.04.3 LTS. (BKH 2016-01-22)
#
# Schedule to run once an hour, at half past the hour, e.g.:
#     $ echo '30 * * * * ~/bin/bwt.sh' | crontab

URL='http://apps.cbp.gov/bwt/display_rss_port.asp?port=250401'
LOC='San Ysidro'
CSV=data/sy.csv

# Create data folder
mkdir -p data

# Output one line of data with a timestamp. Remove HTML tags.
/bin/echo -n `date +"%Y-%m-%d %H:%M:%S,"` >> $CSV
curl -s "$URL" | grep "$LOC" | \
    sed -e 's/<br>/ /g' -e 's/<[^>]*>/,/g' | \
    tr -s "," >> "$CSV" 
