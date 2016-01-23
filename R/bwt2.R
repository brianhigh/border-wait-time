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

# Create a function to separate concatenated fields of node cells
addSep <- function(node) {
    gsub("([A-Za-z])(no|[0-9])", "\\1,\\2", xmlValue(node))
}

# Parse HTML table into dataframe. Use the 3rd row for data values.
dat.l <- data.frame(readHTMLTable(url, trim=TRUE, header=FALSE, which=5))[3,]

# Separate concatenated fields
dat.v <- gsub("([A-Za-z])(no|[0-9])", "\\1,\\2", as.character(unlist(dat.l)))

# Add timestamp
dat.v <- c(timestamp, dat.v)

# Append to CSV
write(paste(dat.v, collapse=","), file=csv, append=TRUE)