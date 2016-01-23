# bwt2.R: Extract border wait time data from HTML table using R.
#
# Tested on Ubuntu 14.04.3 LTS and R version 3.2.3 (2015-12-10).
#
# Schedule to run once an hour, at half past the hour, e.g.:
#     $ echo '30 * * * * ~/bin/bwt2.R' | crontab

url <- "http://apps.cbp.gov/bwt/display_rss_port.asp?port=250401"
loc <- "San Ysidro"
csv <- "data/sy2R.csv"

# Create data folder
dir.create(file.path('data'), showWarnings=FALSE, recursive=TRUE)

# Output one line of data with a timestamp.
timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")

#install.packages("XML")
library(XML)

# Parse HTML table
dat <- data.frame(readHTMLTable(url, skip.rows=5, trim=T, header=F, which=5), 
                    stringsAsFactors=F)

# Separate concatenated fields
dat <- apply(dat[3,], 2, function(x) gsub("([A-Za-z])(no|[0-9])", "\\1,\\2", x))

# Add timestamp
dat <- c(timestamp, dat)

# Append to CSV
write(paste(dat, collapse=","), file=csv, append=TRUE)