#Wild Fire Project 2020                                                 #
#Hacking for Social Sciences - An Applied Guide to Programming with Data#
#Check2

#Set working directory
#setwd("C:/Users/scstepha/Documents/Forschung/Wildfire") #enter working directory here (C:/Users/scstepha/Documents/wildfire)
    #by creating an R-project we can avoid setting the directory

setwd("E:/Wild_fire_project/Unzip_file")
getwd() 

#Working directory Structure
  #Working Directory: Wildfire
    #Folder: Raw_Data [do not write in this folder when processing data]
      #contains "Source/Artes-Vivancos_San-Miguel_2018"
      #contains downloaded data
    #Folder: Processed_Data [used to work with data]

# Downloaded bulk data of wild fire-----

library(data.table)
library(tidyverse)
library(rgdal)
library(rgeos)
library(raster)# for metadata/attributes- vectors or rasters
library(dplyr)
library(dbplyr)
library(ggplot2)
library(sf)
library(raster)
# Read a text file

Wild_fire<-read.delim("Raw_Data/Source/Artes-Vivancos_San-Miguel_2018/datasets/ESRI-GIS_GWIS_wildfire.tab", header = FALSE, sep = "\t")
#Wild_fire<-read.delim("C:/Users/guptasu.D/Downloads/Artes-Vivancos_San-Miguel_2018/datasets/ESRI-GIS_GWIS_wildfire.tab", header = FALSE, sep = "\t")

# Extracted the rows that contain URLs

Wild_fire_url<- Wild_fire[grepl("http", Wild_fire$V1),]

Wild_fire_url1<- Wild_fire_url$V1

typeof(Wild_fire_url1)

# Since the data type is an integer, converted it into character

Final_urls<-as.character(Wild_fire_url1)

#Define URLs

urls<-Final_urls

#Define URL folder where to save the data (destination)

data.folder = "./Raw_Data/"  #evtl. mit tab Raw_Data/ auswählen
#data.folder = "E:/Wild_fire_project/Unzip_file/"

#Get file name from url, with file extention

fname.x <- gsub(".*/(.*)", "\\1", urls)

#Get file name from url, without file extention

fname <- gsub("(.*)\\.zip.*", "\\1", fname.x)


destfile = paste0(data.folder, fname.x)

#download files

for(i in seq_along(urls)){
  download.file(urls[i], destfile[i], mode="wb")
}


###
#Download the database
urldatabase_f="http://hs.pangaea.de/Maps/MCD64A1_burnt-areas/MODIS_GWIS_Final_FireEvents.zip" #final events
urldatabase_a="http://hs.pangaea.de/Maps/MCD64A1_burnt-areas/MODIS_GWIS_Active_FireEvents.zip" #active areas

download.file(urldatabase_f, "Raw_Data//MODIS_GWIS_Final_FireEvents.zip", mode="wb")
download.file(urldatabase_a, "Raw_Data/MODIS_GWIS_Active_FireEvents.zip", mode="wb")

# Processing of data--------

##Unzip files
#for (i in 1:length(destfile)){unzip(destfile[i],exdir=./Raw_Data")}

tmpdir_R <- tempdir()

##Function to read data into R
from_s <-2000
to_s   <-2017
months_s<-c("1_") #"1_","2_","3_","4_","5_","6_","7_","8_","9_","10_","11_","12_"
#The following lines define a string vector to load the sample
sampleyears<-seq.int(from_s, to_s, 1)
sampleyears <- as.character(sampleyears) 
sampleym_s<-c(outer(months_s, sampleyears, FUN=paste0)) #"cross-product" of months and years
loadsample<-fname
sampleym_s = paste(sampleym_s, collapse="|")
grepl(sampleym_s, loadsample)
loadsample <- data.table(loadsample, insample=grepl(sampleym_s, loadsample))
loadsample<-loadsample %>%filter(insample==TRUE)
loadsample<-loadsample$loadsample


   # for(z in loadsample){ #Loop to load shapefiles into R
      #Unzip downloaded data
      #(zipfile<-str_c(file.path("./Raw_Data//"),z,".zip"))
      #unzip(zipfile, exdir = tmpdir_R)
      #Untar downloaded data (use/modify the next two lines if you want to untar to your disk)
      #untar(tarfile = file.path(tempd1, "/",z,".tar"), exdir = "./Raw_Data/Extracted/")
      #testdatashp <- readOGR(dsn = "./Raw_Data/Extracted", "MODIS_BA_GLOBAL_1_1_2001") 
      #(tarfile<-str_c(file.path(tmpdir_R),"\\",z,".tar"))
      #untar(tarfile = tarfile, exdir = tmpdir_R)
      #Read into R

      #assign(paste(z,"_shp",sep = ""),
             #readOGR(dsn = tmpdir_R, z)) #path, filename (here identical))    
    #}
    #unlink(tmpdir_R) #deletes tempfile. Does that work?
    
##Untar files
    
    for(z in loadsample){ #Loop to load shapefiles into R
      #Unzip downloaded data
      (tarfile<-str_c(file.path("./Raw_Data"),"\\",z,".tar"))
      untar(tarfile =tarfile,files = NULL, list = FALSE, exdir = "./Raw_Data/data/")}

      

## crop single shapefile
## read a shapefile
    
shp_spdf <-readOGR ("./Raw_Data/data/MODIS_BA_GLOBAL_1_6_2015.shp")
  
plot (shp_spdf,main="Global map of wildfire Active Areas during June 2015")

## we gave here bounding box to crop Australia (please follow this website to extract the bounding box:
#https://gist.github.com/graydon/11198540
## We choose bounding box because when we were cropping using Australia shapefile, it was very time-consuming.   

## Cropped shapefiles

sub_Australia <- crop(shp_spdf, extent(113.338953078,153.569469029, -43.6345972634, -10.6681857235))

plot(sub_Australia, main="Australia Wildfire Active Areas during June 2015", col.main= "red")

## Write shapefile

Aus1<- shapefile(sub_Australia,"./Raw_Data/data/Austest1.shp" )

## Crop multiple shapefiles

ipath <- "./Raw_Data/data/"
opath <- "./Raw_Data/data/Aus_extract/"

## extract all shapefiles from the folder

ff <- list.files(ipath, pattern="\\.shp$", full.names=TRUE)

stopifnot(length(ff)>0)

fname.x1 <- gsub(".*/(.*)", "\\1", ff)

#Get file name from url, without file extention

fname1 <- gsub("(.*)\\.shp.*", "\\1", fname.x1)

#define destination folder

destfile1 = paste0(opath, fname.x1)


for (f in 1:length(ff)){
  
  r <- shapefile(ff[f])

  rc <- crop(r, extent(113.338953078,153.569469029, -43.6345972634, -10.6681857235))

  shapefile(rc, destfile1[f], overwrite=TRUE)
  
}


Aus1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2015.shp")

Aus2<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2016.shp")

Aus3<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2017.shp")

Aus4<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_7_2015.shp")

Aus5<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_7_2016.shp")

Aus6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_7_2017.shp")


par(mfrow= c(2,4))

plot(Aus1, main="June2015", col.main= "red")

par(new=FALSE)

plot(Aus2, main="June2016", col.main= "red")

par(new=FALSE)

plot(Aus3, main="June2017", col.main= "red")

par(new=FALSE)

plot(Aus4, main="july2015", col.main= "red")

par(new=FALSE)

plot(Aus5, main="july2016", col.main= "red")

par(new=FALSE)

plot(Aus6, main="july2017", col.main= "red")



## Area changes from 2001 to 2017 for June month


Aus_2001_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2001.shp")

Aus_2002_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2002.shp")

Aus_2003_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2003.shp")

Aus_2004_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2004.shp")

Aus_2005_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2005.shp")

Aus_2006_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2006.shp")

Aus_2007_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2007.shp")

Aus_2008_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2008.shp")

Aus_2009_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2009.shp")

Aus_2010_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2010.shp")

Aus_2011_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2011.shp")

Aus_2012_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2012.shp")

Aus_2013_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2013.shp")

Aus_2014_6<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_6_2014.shp")


## extract the area of shapefiles

Aus_2001_6$area_sqkm <- area(Aus_2001_6) / 1000000

Aus_2002_6$area_sqkm <- area(Aus_2002_6) / 1000000

Aus_2003_6$area_sqkm <- area(Aus_2003_6) / 1000000

Aus_2004_6$area_sqkm <- area(Aus_2004_6) / 1000000

Aus_2005_6$area_sqkm <- area(Aus_2005_6) / 1000000

Aus_2006_6$area_sqkm <- area(Aus_2006_6) / 1000000

Aus_2007_6$area_sqkm <- area(Aus_2007_6) / 1000000

Aus_2008_6$area_sqkm <- area(Aus_2008_6) / 1000000

Aus_2009_6$area_sqkm <- area(Aus_2009_6) / 1000000

Aus_2010_6$area_sqkm <- area(Aus_2010_6) / 1000000

Aus_2011_6$area_sqkm <- area(Aus_2011_6) / 1000000

Aus_2012_6$area_sqkm <- area(Aus_2012_6) / 1000000

Aus_2013_6$area_sqkm <- area(Aus_2013_6) / 1000000

Aus_2014_6$area_sqkm <- area(Aus_2014_6) / 1000000

Aus1$area_sqkm <- area(Aus1) / 1000000

Aus2$area_sqkm <- area(Aus2) / 1000000

Aus3$area_sqkm <- area(Aus3) / 1000000


Aus_2001_61<- Aus_2001_6@data

Aus_2002_61 <- Aus_2002_6@data

Aus_2003_61 <-Aus_2003_6@data

Aus_2004_61 <- Aus_2004_6@data

Aus_2005_61 <- Aus_2005_6@data

Aus_2006_61 <- Aus_2006_6@data

Aus_2007_61 <- Aus_2007_6@data

Aus_2008_61 <- Aus_2008_6@data

Aus_2009_61 <- Aus_2009_6@data

Aus_2010_61 <- Aus_2010_6@data

Aus_2011_61<- Aus_2011_6@data

Aus_2012_61<- Aus_2012_6@data

Aus_2013_61 <- Aus_2013_6@data

Aus_2014_61 <- Aus_2014_6@data

Aus_2015_61<- Aus1@data

Aus_2016_61 <- Aus2@data

Aus_2017_61 <- Aus3@data



Aus_2001_61_area<- Aus_2001_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2001_61_area $year<- 2001

Aus_2002_61_area<- Aus_2002_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2002_61_area $year<- 2002

Aus_2003_61_area<- Aus_2003_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2003_61_area $year<- 2003

Aus_2004_61_area<- Aus_2004_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2004_61_area $year<- 2004

Aus_2005_61_area<- Aus_2005_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2005_61_area $year<- 2005

Aus_2006_61_area<- Aus_2006_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2006_61_area $year<- 2006

Aus_2007_61_area<- Aus_2007_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2007_61_area $year<- 2007

Aus_2008_61_area<- Aus_2008_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2008_61_area $year<- 2008

Aus_2009_61_area<- Aus_2009_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2009_61_area $year<- 2009


Aus_2010_61_area<- Aus_2010_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2010_61_area $year<- 2010

Aus_2011_61_area<- Aus_2011_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2011_61_area $year<- 2011


Aus_2012_61_area<- Aus_2012_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2012_61_area $year<- 2012

Aus_2013_61_area<- Aus_2013_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2013_61_area $year<- 2013

Aus_2014_61_area<- Aus_2014_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2014_61_area $year<- 2014

Aus_2015_61_area<- Aus_2015_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2015_61_area $year<- 2015

Aus_2016_61_area<- Aus_2016_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2016_61_area $year<- 2016


Aus_2017_61_area<- Aus_2017_61 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2017_61_area $year<- 2017

Final_dataset<- rbind(Aus_2001_61_area, Aus_2002_61_area, Aus_2003_61_area, Aus_2004_61_area, Aus_2005_61_area
                      , Aus_2006_61_area, Aus_2007_61_area, Aus_2008_61_area, Aus_2009_61_area, Aus_2010_61_area
                      , Aus_2011_61_area, Aus_2012_61_area, Aus_2013_61_area, Aus_2014_61_area, Aus_2015_61_area
                      , Aus_2016_61_area, Aus_2017_61_area)


## Area changes from 2001 to 2017 for June month

Aus_2001_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2001.shp")

Aus_2002_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2002.shp")

Aus_2003_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2003.shp")

Aus_2004_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2004.shp")

Aus_2005_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2005.shp")

Aus_2006_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2006.shp")

Aus_2007_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2007.shp")

Aus_2008_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2008.shp")

Aus_2009_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2009.shp")

Aus_2010_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2010.shp")

Aus_2011_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2011.shp")

Aus_2012_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2012.shp")

Aus_2013_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2013.shp")

Aus_2014_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2014.shp")

Aus_2015_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2015.shp")

Aus_2016_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2016.shp")

Aus_2017_1<- readOGR("./Raw_Data/data/Aus_extract/MODIS_BA_GLOBAL_1_1_2017.shp")


Aus_2001_1$area_sqkm <- area(Aus_2001_1) / 1000000

Aus_2002_1$area_sqkm <- area(Aus_2002_1) / 1000000

Aus_2003_1$area_sqkm <- area(Aus_2003_1) / 1000000

Aus_2004_1$area_sqkm <- area(Aus_2004_1) / 1000000

Aus_2005_1$area_sqkm <- area(Aus_2005_1) / 1000000

Aus_2006_1$area_sqkm <- area(Aus_2006_1) / 1000000

Aus_2007_1$area_sqkm <- area(Aus_2007_1) / 1000000

Aus_2008_1$area_sqkm <- area(Aus_2008_1) / 1000000

Aus_2009_1$area_sqkm <- area(Aus_2009_1) / 1000000

Aus_2010_1$area_sqkm <- area(Aus_2010_1) / 1000000

Aus_2011_1$area_sqkm <- area(Aus_2011_1) / 1000000

Aus_2012_1$area_sqkm <- area(Aus_2012_1) / 1000000

Aus_2013_1$area_sqkm <- area(Aus_2013_1) / 1000000

Aus_2014_1$area_sqkm <- area(Aus_2014_1) / 1000000

Aus_2015_1$area_sqkm <- area(Aus_2015_1) / 1000000

Aus_2016_1$area_sqkm <- area(Aus_2016_1) / 1000000

Aus_2017_1$area_sqkm <- area(Aus_2017_1) / 1000000



Aus_2001_11<- Aus_2001_1@data

Aus_2002_11 <- Aus_2002_1@data

Aus_2003_11 <-Aus_2003_1@data

Aus_2004_11 <- Aus_2004_1@data

Aus_2005_11 <- Aus_2005_1@data

Aus_2006_11 <- Aus_2006_1@data

Aus_2007_11 <- Aus_2007_1@data

Aus_2008_11 <- Aus_2008_1@data

Aus_2009_11 <- Aus_2009_1@data

Aus_2010_11 <- Aus_2010_1@data

Aus_2011_11<- Aus_2011_1@data

Aus_2012_11<- Aus_2012_1@data

Aus_2013_11 <- Aus_2013_1@data

Aus_2014_11 <- Aus_2014_1@data

Aus_2015_11<- Aus_2015_1@data

Aus_2016_11 <- Aus_2016_1@data

Aus_2017_11 <- Aus_2017_1@data



Aus_2001_11_area<- Aus_2001_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2001_11_area $year<- 2001

Aus_2002_11_area<- Aus_2002_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2002_11_area $year<- 2002

Aus_2003_11_area<- Aus_2003_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2003_11_area $year<- 2003

Aus_2004_11_area<- Aus_2004_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2004_11_area $year<- 2004

Aus_2005_11_area<- Aus_2005_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2005_11_area $year<- 2005

Aus_2006_11_area<- Aus_2006_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2006_11_area $year<- 2006

Aus_2007_11_area<- Aus_2007_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2007_11_area $year<- 2007

Aus_2008_11_area<- Aus_2008_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2008_11_area $year<- 2008

Aus_2009_11_area<- Aus_2009_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2009_11_area $year<- 2009


Aus_2010_11_area<- Aus_2010_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2010_11_area $year<- 2010

Aus_2011_11_area<- Aus_2011_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2011_11_area $year<- 2011


Aus_2012_11_area<- Aus_2012_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2012_11_area $year<- 2012

Aus_2013_11_area<- Aus_2013_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2013_11_area $year<- 2013

Aus_2014_11_area<- Aus_2014_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2014_11_area $year<- 2014

Aus_2015_11_area<- Aus_2015_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2015_11_area $year<- 2015

Aus_2016_11_area<- Aus_2016_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2016_11_area $year<- 2016


Aus_2017_11_area<- Aus_2017_11 %>%
  summarize_if(is.numeric, sum, na.rm=TRUE)

Aus_2017_11_area $year<- 2017

Final_dataset1<- rbind(Aus_2001_11_area, Aus_2002_11_area, Aus_2003_11_area, Aus_2004_11_area, Aus_2005_11_area
                      , Aus_2006_11_area, Aus_2007_11_area, Aus_2008_11_area, Aus_2009_11_area, Aus_2010_11_area
                      , Aus_2011_11_area, Aus_2012_11_area, Aus_2013_11_area, Aus_2014_11_area, Aus_2015_11_area
                      , Aus_2016_11_area, Aus_2017_11_area)
Final_dataset$month<- "June"

Final_dataset1$month<- "January"

Final_dataset2<- rbind(Final_dataset, Final_dataset1)


p<-ggplot(data=Final_dataset2, aes(x=year, y=area_sqkm, color = month)) +
  geom_bar(stat="identity",  position=position_dodge())+ 
  labs(title="Active wild fire areas in Australia from 2001-2017 in January and June", y= "Area [sqkm]", x = "Year [-]") + 
  theme_minimal()+theme(axis.text=element_text(size=10, color = "black"),
                                       axis.title=element_text(size=12,face="bold"))+
  theme(plot.title = element_text(color = "brown"))+theme(panel.border = element_rect(colour = "black", fill=NA, size=1))+
  scale_x_continuous(limits = c(2000,2018), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0,120000), expand = c(0, 0)) +theme_bw()+dev.new(width=2, height=2) 
p


par(mfrow= c(2,2))

plot(Aus_2001_1, main="Janaury 2001", col.main= "red")

par(new=FALSE)

plot(Aus_2001_6, main="June 2001", col.main= "red")

par(new=FALSE)

plot(Aus_2012_1, main="Janaury 2012", col.main= "red")

par(new=FALSE)

plot(Aus_2012_6, main="June 2012", col.main= "red")


### database_wildfire

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

setwd("E:/Wild_fire_project/Unzip_file")
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
rs1 <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.final_ba_2000 LIMIT 1")
dbFetch(rs1)     # worked out!
# Active areas
rs2 <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.active_areas_2001 LIMIT 2")
dbFetch(rs2)     # worked out!




### Load data for a map of Australia
library(geojsonsf)
australia_sf <- geojson_sf("./Raw_Data/geojson/2c97c1efc6a175f3c06b62dae125c372.geojson")

# Extract coordinates for the corresponding boundary box
head(australia_sf,3)
bbox_list <- lapply(st_geometry(australia_sf), st_bbox)
View(bbox_list)




### Query data for one year only and plot it
# Query it
rs3 <- dbSendQuery(con, "SELECT * FROM nasa_modis_ba.active_areas_2001 WHERE nasa_modis_ba.active_areas_2001.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693)")
# Fetch it in an object called dbout (database output)
dbout <- dbFetch(rs3)  
# Add another variable that is a converted version of the wkb_geometry variable (namely a sfc_geometry)
dbout$sfc_geometry <- st_as_sfc(
  dbout$wkb_geometry,
  EWKB = TRUE,
  spatialite = FALSE,
  pureR = FALSE,
  crs = NA_crs_
)

## Normal plot                                                                  # plot works but it takes one or two minutes
#plot(dbout$sfc_geometry)

## Another plot                                                                 # plot works but it takes one or two minutes
# ggplot() +
#  geom_sf(data = dbout$sfc_geometry, colour = 'red') +
#  guides(fill = guide_none())

 #Plot with borders of Australia                                               # plot works but it takes three or four minutes
ggplot(australia_sf) +
 geom_sf() +
  geom_sf(data = dbout$sfc_geometry, colour = 'red') +
 labs(
    title = "Active Areas",
    subtitle = "Australia in 2001",
    x = "Latitude",
    y = "Longitude"
  ) +
   guides(fill = guide_none())
# Saving only workes if a folder called "maps" is created next to the folder "Raw_Data"
# ggsave("maps/active_areas_Australia_2001.png", width = 8, height = 8, dpi = 300, units = "in")
# However, it takes a while to be able to open it after saving/storing it in the the folder "maps"
# (propably cause its size is too large)




### Two alternatives to load several tables/elements (of different years) at once

### 1. Alternative: Use "UNION ALL" in dbSendQuery()
# Query it
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
# Fetch it in an object called db_out (database_output)
db_out <- dbFetch(rs)                                                           # this is necessary but takes one or two minutes 
# Add another variable that is a converted version of the wkb_geometry variable (namely a sfc_geometry)
db_out$sfc_geometry <- st_as_sfc(                                               # this is necessary but takes two or three minutes 
  db_out$wkb_geometry,
  EWKB = TRUE,
  spatialite = FALSE,
  pureR = FALSE,
  crs = NA_crs_
)
# Worked out as intended:
head(db_out)
class(db_out)
class(db_out$wkb_geometry)
class(db_out$sfc_geometry)     # can be used for plotting
class(db_out$burndate)

# Add additional time variables
library(lubridate)
db_out$burn_year <- year(db_out$burndate)
db_out$burn_month <- month(db_out$burndate)
library(zoo)
db_out$burn_yearmon <-                                                          # this is NOT necessary and takes one or two minutes
  as.yearmon(paste0(db_out$burn_year, "-", db_out$burn_month))


# Let's continue by sub-setting (e.g. data frame for active areas in 2001 only)
active_2001_jan_df <- db_out %>% 
  dplyr::filter(burn_year == 2001, burn_month == 1)
# Open question:
# Why is there a difference the length of the following two data frames?
dim(active_2001_jan_df)[1]

# Something that enters because of UNION ALL??

ggplot(australia_sf) +
  geom_sf() +
  geom_sf(data = active_2001_jan_df$sfc_geometry, colour = 'red') +
  labs(
    title = "Active Areas",
    subtitle = "Australia in 2001",
    x = "Latitude",
    y = "Longitude"
  ) +
  guides(fill = guide_none())

### 2. Alternative: Using sprint() in a loop to load all years at once 
## Test outside of the loop
# years <- 2001:2018
# rs_test <- dbSendQuery(con, sprintf("SELECT * FROM nasa_modis_ba.active_areas_%.f WHERE nasa_modis_ba.active_areas_%.f.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693)", years[1], years[1])) 
# dbFetch(rs_test)                                                                # works!
# 
# ## Loop
# # Create a vector for the relevant years (time period of the provided dataset)
# years <- 2001:2018
# # Create an empty output list with the correct length
# rs_test <- vector("list", length(2001:2018))
# # Actual loop
# for (i in 1:18){
#   # Store query in year/iteration i
#   rs_test[[i]] <- dbSendQuery(con, sprintf("SELECT * FROM nasa_modis_ba.active_areas_%.f WHERE nasa_modis_ba.active_areas_%.f.wkb_geometry && ST_MakeEnvelope(72.57811, -55.11579,  167.9966, -9.140693)", years[i], years[i])) 
#   # Print the current i and year to see whether the loop really runs through as intended
#   print(i)
#   print(years[i])
# }                                                                               # loop runs through as intended BUT...
# # ... the following commands show that the data was not stored as intended in the output vector rs_test (in every single iteration of the loop)
# dbFetch(rs_test[[1]])
# rs_test[[1]]@sql
# rs_test[[1]]@conn
# rs_test[[1]]@ptr
# rs_test[[1]]@bigint
# 




