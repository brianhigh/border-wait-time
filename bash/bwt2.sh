#!/bin/sh
# bwt2.sh: Extract border wait time data from XML using xml2csv.
#
# You can install xml2csv by following instructions found here:
# https://pypi.python.org/pypi/xmlutils
#
# Tested on Ubuntu 14.04.3 LTS and Python 2.7.6. (BKH 2016-01-22)
#
# Schedule to run once an hour, at half past the hour, e.g.:
#     $ echo '30 * * * * ~/bin/bwt2.sh' | crontab

URL='http://apps.cbp.gov/bwt/bwt.xml'
LOC='San Ysidro'
CSV=data/sy2.csv

# Create data folder
mkdir -p data

# Output one line of data with a timestamp.
/bin/echo -n `date +"%Y-%m-%d %H:%M:%S,"` >> "$CSV" 
curl -s -o bwt.xml "$URL" 
xml2csv --input bwt.xml --output bwt.csv --tag 'port' 1>/dev/null
grep "$LOC" bwt.csv >> "$CSV" 
rm -f bwt.csv bwt.xml

