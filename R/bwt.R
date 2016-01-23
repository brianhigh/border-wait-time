# bwt.R: Extract border wait time data from XML using R.
#
# Tested on Ubuntu 14.04.3 LTS and R version 3.2.3 (2015-12-10).
#
# Schedule to run once an hour, at half past the hour, e.g.:
#     $ echo '30 * * * * ~/bin/bwt.R' | crontab

url <- "http://apps.cbp.gov/bwt/bwt.xml"
loc <- "San Ysidro"
csv <- "data/syR.csv"

# Create data folder
dir.create(file.path('data'), showWarnings=FALSE, recursive=TRUE)

# Output one line of data with a timestamp.
timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")

#install.packages("XML")
library(XML)

# Parse XML
xmlfile <- xmlTreeParse(url)
xmltop = xmlRoot(xmlfile)

# Find port of entry
ports <- sapply(getNodeSet(xmltop, "/border_wait_time/port/port_name"), 
                xmlValue)
ns <- getNodeSet(xmltop, '/border_wait_time/port')
loc.ns <- ns[[grep(loc, ports)]]

# Store top-level node attributues as a vector
loc.top <- xmlSApply(loc.ns, function(x) {
    xmlSApply(x, function(y) xmlValue(y, recursive = F))
    })[c(1:7)]
loc.top.v <-as.vector(unlist(loc.top))

# Store child node attributues as a vector
loc.children.v <- vector()
for (i in c("commercial_vehicle_lanes", 
            "passenger_vehicle_lanes", 
            "pedestrian_lanes")) {
    for (j in names(xmlSApply(loc.ns[[i]], xmlValue))) {
        loc.children.v <- c(loc.children.v, 
                            xmlSApply(loc.ns[[i]][[j]], xmlValue))
    }
}

# Combine vectors
loc.v <- c(timestamp, loc.top.v, loc.children.v)

# Remove values of "character(0)"
loc.v <- gsub("character(0)", "", loc.v, fixed = TRUE)

# Append to CSV
loc.m <- as.matrix(t(loc.v))
write.table(loc.m, file = csv, sep = ",", row.names = FALSE,
            col.names = FALSE, append=TRUE)