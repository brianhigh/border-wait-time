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

#install.packages("XML")
library(XML)

# Parse HTML into dataframe. Select the 3rd row of values. Store as a vector.
dat <- readHTMLTable(url, trim=TRUE, header=FALSE, which=5, 
                       data.frame=TRUE, stringsAsFactors=FALSE)[3,]

# Separate the concatenated fields
dat <- gsub("([A-Za-z])(no|[0-9])", "\\1,\\2", dat)

# Remove extra text
dat <- gsub(" lane\\(s\\) open| min delay", "", dat)

# Add a timestamp
dat <- c(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), dat)

# Append to CSV. Note: Did not quote or escape. May not conform to RFC 4180.
write(paste(dat, collapse=","), file=csv, append=TRUE)