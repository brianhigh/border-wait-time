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

# We can't just run xmlValue on the whole XML node, as the cells run together
#loc.v <- as.vector(unlist(xmlSApply(loc.ns, xmlValue)))
#loc.v[8]
#[1] "25At 1:00 pm PSTdelay6010At 1:00 pm PSTdelay108At 1:00 pm PSTdelay407"

# Store top-level node attributues as a vector
loc.top.v <- as.vector(unlist(xmlSApply(loc.ns, xmlValue)))[c(1:6)]

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

# Combine vectors with a timestamp
loc.v <- c(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), loc.top.v, loc.children.v)

# Remove values of "character(0)"
loc.v <- gsub("character(0)", "", loc.v, fixed = TRUE)

# Append to CSV
loc.m <- as.matrix(t(loc.v))
write.table(loc.m, file = csv, sep = ",", row.names = FALSE,
            col.names = FALSE, append=TRUE)