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
library(odbc)
library(sf)
#library(sparklyr)
#library(sparklyr.nested)
#library(Rcpp)



## Set crucial/useful option
#options(na.action = na.warn)    # Option set as such that R will return a warning if there are any missings

# Check working directory
getwd()




### NEXT STEPS
## 1) Need to find out what needs to be specified after "SELECT * FROM nasa_modis_ba.final_ba_2000 ......"
# DONE
## 2) Develop an approach loading several tables/elements (of different years) at once
# DONE
## 3) Find out how to load boundary-data (as wkb-format?)
# DONE
## 4) ???




### SQL queries -------------------------------------------------------------
### TASK:
# The idea is to send the SQL queries as (sanitized) text strings to the DB



### Set up a connection with the gwis database

## Pre-definitions
db_name <- "gwis"
host_name <- "localhost"
username <- "user1"
password <- "1"

## Connect with the gwis database
con <- dbConnect(drv = RPostgres::Postgres(),
                 #RMySQL::MySQL(),   # ?
                 dbname = db_name,
                 host = host_name,         
                 port = 5432,
                 user = username,
                 password = password)  
#dbDisconnect(con)

# Other useful commands
dbListTables(con)
#dbReadTable(con, "final_ba_2000")
# Fehler: Failed to prepare query: FEHLER:  Relation ?final_ba_2000? existiert nicht
# LINE 1: SELECT * FROM  "final_ba_2000"
# ^



### First tests with limited number of elements loaded
# Final areas
rs <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.final_ba_2000 LIMIT 1")
dbFetch(rs)     # worked out!
# Active areas
rs <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.active_areas_2001 LIMIT 2")
dbFetch(rs)     # worked out!



### Query data for one year only and plot it
# Query it
rs <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.active_areas_2001 WHERE nasa_modis_ba.active_areas_2001.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693)")
# Fetch it
dbout <- dbFetch(rs)  
# Add another variable that is a converted version of the wkb_geometry variable (namely a sfc_geometry)
dbout$sfc_geometry <- st_as_sfc(
  dbout$wkb_geometry,
  EWKB = TRUE,
  spatialite = FALSE,
  pureR = FALSE,
  crs = NA_crs_
)

# Normal plot
plot(dbout_sfc)
# Another plot
ggplot() + geom_sf(data=dbout_sfc,colour='red') + guides(fill = guide_none())

# Get map of Australia
library(geojsonsf)
australia_sf <- geojson_sf("Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson")
# Plot with borders of Australia
ggplot(australia_sf) + 
  geom_sf() +
  geom_sf(data = dbout_sfc, colour = 'red') +  
  guides(fill = guide_none()) 




### Boundary Box
head(australia_sf,3)
bbox_list <- lapply(st_geometry(australia_sf), st_bbox)
View(bbox_list)




### Two options to load several tables/elements (of different years) at once

### 1. Alternative: Use "UNION ALL" in dbSendQuery()
rs <- dbSendQuery(con, 
                  "(SELECT * FROM nasa_modis_ba.active_areas_2001 
                  WHERE nasa_modis_ba.active_areas_2001.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2002
                  WHERE nasa_modis_ba.active_areas_2002.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2003
                  WHERE nasa_modis_ba.active_areas_2003.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2004
                  WHERE nasa_modis_ba.active_areas_2004.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2005
                  WHERE nasa_modis_ba.active_areas_2005.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2006
                  WHERE nasa_modis_ba.active_areas_2006.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2007
                  WHERE nasa_modis_ba.active_areas_2007.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2008
                  WHERE nasa_modis_ba.active_areas_2008.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2009
                  WHERE nasa_modis_ba.active_areas_2009.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2010
                  WHERE nasa_modis_ba.active_areas_2010.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2011
                  WHERE nasa_modis_ba.active_areas_2011.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2012
                  WHERE nasa_modis_ba.active_areas_2012.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2013
                  WHERE nasa_modis_ba.active_areas_2013.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2014
                  WHERE nasa_modis_ba.active_areas_2014.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2015
                  WHERE nasa_modis_ba.active_areas_2015.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2016
                  WHERE nasa_modis_ba.active_areas_2016.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2017
                  WHERE nasa_modis_ba.active_areas_2017.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))
                  UNION ALL
                  (SELECT * FROM nasa_modis_ba.active_areas_2018
                  WHERE nasa_modis_ba.active_areas_2018.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693))")
# Fetch in an object alled db_out (database_output)
db_out <- dbFetch(rs)  
# Add another variable that is a converted version of the wkb_geometry variable (namely a sfc_geometry)
db_out$sfc_geometry <- st_as_sfc(
  db_out$wkb_geometry,
  EWKB = TRUE,
  spatialite = FALSE,
  pureR = FALSE,
  crs = NA_crs_
)
# Worked out as inteded:
class(db_out)
class(db_out$wkb_geometry)
class(db_out$sfc_geometry)     # can be used for plotting
class(db_out$burndate)

# Add additional time variables
library(lubridate)
db_out$burn_year <- year(db_out$burndate)
db_out$burn_month <- month(db_out$burndate)
library(zoo)
db_out$burn_yearmon <- as.yearmon(paste0(db_out$burn_year, "-", db_out$burn_month))


# Let's continue by sub-setting (e.g. data frame for active areas in 2001 only)
active_2001_df <- db_out %>% 
  dplyr::filter(burn_year == 2001)
# Open question:
# Why is there a difference the length of the following two data frames?
dim(active_2001_df)[1]
dim(dbout)[1]
# Something that enters because of UNION ALL??






### 2. Alternative: Using sprint() in a loop to load all years at once 
## Test outside of the loop
years <- 2001:2018
rs_test <- dbSendQuery(con, sprintf("SELECT * FROM nasa_modis_ba.active_areas_%.f WHERE nasa_modis_ba.active_areas_%.f.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693)", years[1], years[1])) 
dbFetch(rs_test)      # works!

## Loop
# Create a vector for the relevant years (time period of the provided dataset)
years <- 2001:2018
# Create an empty output list with the correct length
rs2 <- vector("list", length(2001:2018))
# Actual loop
for (i in 1:18){
  # Store query in year/iteration i
  rs2[[i]] <- dbSendQuery(con, sprintf("SELECT * FROM nasa_modis_ba.active_areas_%.f WHERE nasa_modis_ba.active_areas_%.f.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693)", years[i], years[i])) 
  # Print the current i and year to see whether the loop really runs through as intended
  print(i)
  print(years[i])
}
# The following commands show that the loop ran through but the data was not stored as intended in every of the 18 elements of the loop
dbFetch(rs2[[1]])
rs2[[1]]@sql
rs2[[1]]@conn
rs2[[1]]@ptr
rs2[[1]]@bigint






# Try to acces boundary data (Stephan) ------------------------------------
library(geojsonR)
boundary_aus= FROM_GeoJson(url_file_string = "Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson")
#it works to read in the data set as a large list

#plot(boundary_aus)
#df_boundary_aus<-tidy(boundary_aus)

#library(geojsonio)

#file <- system.file("Raw_Data/geojson/", "2c97c1efc6a175f3c06b62dae125c372.geojson", package = "geojsonio")
#data_file <- "Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson"
#boundary_aus<-geojson_read(data_file, what = "sp")
#states <- geojson_read("Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson", what = "sp")




#library(rgdal)
#boundary_a<-readOGR("Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson", layer="2c97c1efc6a175f3c06b62dae125c372")
#https://stackoverflow.com/questions/50949028/readogr-cannot-open-layer-error
#boundary_b <- readOGR("Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson", "2c97c1efc6a175f3c06b62dae125c372")
#I get error messages with both rgdal and geojsonio

library(geojsonsf)
australia_sf <- geojson_sf("Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson")
ggplot(australia_sf) + geom_sf() + guides(fill = guide_none())
#it works to plot the map

rs <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.active_areas_2001 LIMIT 2")
wkbr<-dbFetch(rs)    #this works for me 
class(wkbr) #
class(wkbr$wkb_geometry) #

wkbr2<-st_as_sfc(
  wkbr$wkb_geometry,
  EWKB = TRUE,
  spatialite = FALSE,
  pureR = FALSE,
  crs = NA_crs_
)
plot(wkbr2)

ggplot() + geom_sf(data=wkbr2,colour='red') + guides(fill = guide_none()) + coord_sf(xlim = c(-81, -80), ylim = c(26, 27), expand = FALSE)
ggplot(australia_sf) + geom_sf() +geom_sf(data=wkbr2,colour='red')+  guides(fill = guide_none()) 



#dbdisconnect important?

#library(broom)
#df_boundary_aus<-tidy(geo)


#Boundary Box
head(australia_sf,3)
bbox_list <- lapply(st_geometry(australia_sf), st_bbox)
View(bbox_list)







# Appendix (Maxl) ---------------------------------------------------------

## sprintf()
# sprintf("%f", pi)
# sprintf("%.3f", pi)
# sprintf("%1.0f", pi)
# sprintf("%5.1f", pi)
# sprintf("%05.1f", pi)


# Query
# data <- dbGetQuery(con, 'SELECT TOP 2
#                          ogc_fid, 
#                          id,
#                          initialdate,
#                          finaldate,
#                          geom,
#                          geom.STGeometryType() geom_type,
#                          geom.STSrid STSrid
#                          FROM nasa_modis_ba.final_ba_2000')
# rawToHex(data$geom[1])
# 
# mytest <- st_read(con, 
#                   geometry_column = "geom", 
#                   query = 
#                     "select geometry::STGeomFromText('POLYGON ((0 0, 1.5 0, 1.5 1.5, 0 1.5, 0 0))', 0).STAsBinary() as geom union all
#                   select geometry::Parse('CIRCULARSTRING(0 0, 1 1.10, 2 2.3246, 0 7, -3 2.3246, -1 2.1082, 0 0)').STAsBinary() as geom;")
# 
# plot(mytest)


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



## Further links
# https://therinspark.com/extensions.html#spatial
# https://stackoverflow.com/questions/60927929/querying-sql-server-geospatial-data-from-r
# https://medium.com/rv-data/working-with-spatial-databases-and-r-43f37ea0d499
# https://github.com/tidyverse/dplyr/issues/2055
