#Wild Fire Project 2020                                                 #
#Hacking for Social Sciences - An Applied Guide to Programming with Data#

#Set working directory
setwd("C:/Users/scstepha/Documents/Forschung/Wildfire") #enter working directory here (C:/Users/scstepha/Documents/wildfire)
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

data.folder = "./Raw_Data/"
#data.folder = "E:/Wild_fire_project/"

#Get file name from url, with file extention

fname.x <- gsub(".*/(.*)", "\\1", urls)

#Get file name from url, without file extention

fname <- gsub("(.*)\\.zip.*", "\\1", fname.x)


destfile = paste0(data.folder, fname.x)

#download files

for(i in seq_along(urls)){
  download.file(urls[i], destfile[i], mode="wb")
}

# Processing of data--------

tmpdir_R <- tempdir()

##Read data into R
  #enter years here for which you want to load monthly shapefiles into R
  from_s <-2015
  to_s   <-2017
  months_s<-c("6_","7_") #"1_","2_","3_","4_","5_","6_","7_","8_","9_","10_","11_","12_"
  #The following lines define a string vector to load the sample
    sampleyears<-seq.int(from_s, to_s, 1)
    sampleyears <- as.character(sampleyears) 
    sampleym_s<-c(outer(months_s, sampleyears, FUN=paste0)) #"cross-product" of months and years
    loadsample<-fname
    sampleym_s = paste(sampleym_s, collapse="|")
    grepl(sampleym_s, loadsample)
    loadsample <- data.table(loadsample, insample=grepl(sampleym_s, loadsample))
    loadsample<-loadsample %>%
        filter(insample==TRUE)
    loadsample<-loadsample$loadsample
  
  for(z in loadsample){ #Loop to load shapefiles into R
    #Unzip downloaded data
      (zipfile<-str_c(file.path("./Raw_Data//"),z,".zip"))
      unzip(zipfile, exdir = tmpdir_R)
    #Untar downloaded data (use/modify the next two lines if you want to untar to your disk)
      #untar(tarfile = file.path(tempd1, "/",z,".tar"), exdir = "./Raw_Data/Extracted/")
      #testdatashp <- readOGR(dsn = "./Raw_Data/Extracted", "MODIS_BA_GLOBAL_1_1_2001") 
      (tarfile<-str_c(file.path(tmpdir_R),"\\",z,".tar"))
      untar(tarfile = tarfile, exdir = tmpdir_R)
    #Read into R
      assign(paste(z,"_shp",sep = ""),
             readOGR(dsn = tmpdir_R, z)) #path, filename (here identical))    
  }
    unlink(tmpdir_R) #deletes tempfile. Does that work?

    
  

