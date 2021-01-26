### Wild Fire Project 2020/2021
## Hacking for Social Sciences - An Applied Guide to Programming with Data
### Author: Maximilian Amberg
## Current date:
Sys.Date()


# Clear the global environment
rm(list = ls())




### Pre-settings

## Load usual libraries 
library(tidyverse)
library(ggplot2)
library(readxl)
library(writexl)
library(dplyr)
# library(plyr)
# library(forcats)
# library(readxl)
# library(writexl)
# library(haven)
# library(scales)
# library(plm)
# library(data.table)

## Load specific libraries
library(DBI)
library(RPostgres)
#library(sparklyr)
#library(sparklyr.nested)
#library(Rcpp)



## Set crucial/useful option
#options(na.action = na.warn)    # Option set as such that R will return a warning if there are any missings

# Check working directory
getwd()





### SQL queries -------------------------------------------------------------
### TASK:
# The idea is to send the SQL queries as (sanitized) text strings to the DB. 

## Matthias: 
# Something like:
# con <- dbConnect(drv = Postgres(), 
#                  dbname = unname(dbname), 
#                  user = unname(user),
#                  host = unname(host), 
#                  password = unname(passwd), 
#                  port = unname(port),
#                  options = options)
# dbGetQuery(con, "SELECT * FROM myschema.mytable WHERE id > 100")
# SELECT * FROM nasa_modis_ba.active_areas_2001 LIMIT 10;
# dbSendQuery(con, "SELECT * FROM bla-bla LIMIT 1")
# dbGetQuery(con, "dsdfskl;k;")
# WHERE wkb_geometry ... in Australia ...
# leaflet in the background is then overlayed

## Own implementation
# Connect with gwis database
con <- dbConnect(drv = RPostgres::Postgres(),
                 #RMySQL::MySQL(),   # ?
                 dbname = "gwis",
                 host = "localhost",         
                 port = 5432,
                 user = "user1",
                 password = "1")  
#dbDisconnect(con)

# First tests with limited number of elements loaded
rs <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.final_ba_2000 LIMIT 1")
dbFetch(rs)     # worked out!
rs <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.final_ba_2000 LIMIT 2")
dbFetch(rs)     # worked out!

# Other useful commands
dbListTables(con)
#dbReadTable(con, "final_ba_2000")
# Fehler: Failed to prepare query: FEHLER:  Relation »final_ba_2000« existiert nicht
# LINE 1: SELECT * FROM  "final_ba_2000"
# ^




### NEXT STEPS
## 1) Need to find out what needs to be specified after "SELECT * FROM nasa_modis_ba.final_ba_2000 ......"
## Several variable names: ogc_fid, id, initialdate, finaldate, and geom
## 2) Develop an approach loading several tables/elements (of different years) at once




### Two options to load several tables/elements (of different years) at once

## 1. Alternative: Using sprint() in a loop to load all years at once 
# Test outside of the loop
i <- 2000
rs <- dbSendQuery(con, sprintf("SELECT * FROM nasa_modis_ba.final_ba_%.f LIMIT 1", i))
dbFetch(rs)      # works!

# Create an empty output list with the correct length
rs <- vector("list", length(2000:2018))
# Actual loop
for (i in 2000:2018){
  # Store query in year/iteration i
  rs[[i]] <- dbSendQuery(con, sprintf("SELECT * FROM nasa_modis_ba.final_ba_%.f LIMIT 1", i))
  # Render this element to see whether it worked out
  dbFetch(rs[[i]])     # has not worked out so far!
}
#dbFetch(rs[[1]])




## 2. Alternative: Use "UNION ALL" in dbSendQuery()







# Appendix: Maxl ----------------------------------------------------------

## sprintf()
# sprintf("%f", pi)
# sprintf("%.3f", pi)
# sprintf("%1.0f", pi)
# sprintf("%5.1f", pi)
# sprintf("%05.1f", pi)




