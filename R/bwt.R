# bwt.R: Extract border wait time data from XML using R.
#
# Tested on Ubuntu 18.04.5 LTS and R version 3.6.3 (2020-02-29).
#
# Schedule to run once an hour, at half past the hour, e.g.:
#     $ echo '30 * * * * Rscript ~/bin/bwt.R' | crontab

# Define variables
url <- "https://bwt.cbp.gov/xml/bwt.xml"
loc <- "San Ysidro"

# Create data folder
data_dir <- 'data'
dir.create(file.path(data_dir), showWarnings=FALSE, recursive=TRUE)

# Load packages, installing as needed
if (!require("pacman")) install.packages("pacman")
pacman::p_load(xml2, dplyr, purrr)

# Parse XML
xml <- read_xml(url)

# Get ports
ports_lst <- as_list(xml_find_all(xml, "/border_wait_time/port"))
names(ports_lst) <- sapply(ports_lst, function(x) x$port_number)
ports <- ports_lst %>% 
  map(.x = ., .f = ~as_tibble(flatten(.x[1:10]))) %>%
  bind_rows(.id = "port_number")

# Get lane data
lane_types <- c("passenger_vehicle_lanes", "commercial_vehicle_lanes")
lane_type <- rep(lane_types, each = length(ports_lst))
lane_data <- map2(.x = rep(ports_lst, 2),
     .y = lane_type, 
     .f = ~as_tibble(flatten(.x[[.y]]$standard_lanes), .y = .y)) %>%
  bind_rows(.id = "port_number") %>%
  mutate(lane_type = lane_type)

# Find port of entry
port_num <- ports %>% 
  filter(port_name == loc) %>%
  pull(port_number)

# Filter data for port of entry
port_data <- inner_join(ports %>% filter(port_number %in% port_num),
                        lane_data %>% filter(port_number %in% port_num),
                        by = "port_number")

# Write output to csv
csv <- file.path(data_dir, "syR.csv")
write.csv(port_data, csv, row.names = FALSE)
