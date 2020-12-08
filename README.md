Wild Fire Project 2020
================

  - [Downloaded bulk data of wild
    fire](#downloaded-bulk-data-of-wild-fire)
  - [Processing of data](#processing-of-data)

\#Wild Fire Project 2020

\#Hacking for Social Sciences - An Applied Guide to Programming with
Data\#

# Downloaded bulk data of wild fire

``` {r

library(data.table)

# Read a text file

Wild_fire<-read.delim("C:/Users/guptasu.D/Downloads/Artes-Vivancos_San-Miguel_2018/datasets/ESRI-GIS_GWIS_wildfire.tab", header = FALSE, sep = "\t")

# Extracted the rows that contain URLs

Wild_fire_url<- Wild_fire[grepl("http", Wild_fire$V1),]

Wild_fire_url1<- Wild_fire_url$V1

typeof(Wild_fire_url1)

# Since data type is integer, converted it into character

Final_urls<-as.character(Wild_fire_url1)

#Define URLs

urls<-Final_urls

#Define URL folder where to save the data (destination)

data.folder = "E:/Wild_fire_project/"

#Get file name from url, with file extention

fname.x <- gsub(".*/(.*)", "\\1", urls)

#Get file name from url, without file extention

fname <- gsub("(.*)\\.zip.*", "\\1", fname.x)


destfile = paste0(data.folder, fname.x)

#download files

for(i in seq_along(urls)){
  download.file(urls[i], destfile[i], mode="wb")
}
```

# Processing of data
for (i in 1:length(destfile)){unzip(destfile[i],exdir="E:/Wild_fire_project/Unzip_file")}

tmpdir_R <- tempdir()

##Read data into R
  #enter years and months here for which you want to load monthly shapefiles into R
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
    loadsample<-loadsample %>%filter(insample==TRUE)
    loadsample<-loadsample$loadsample
    
  
  for(z in loadsample){ #Loop to load shapefiles into R
    #Unzip downloaded data
      (tarfile<-str_c(file.path("E:/Wild_fire_project/Unzip_file"),"\\",z,".tar"))
    untar(tarfile =tarfile,files = NULL, list = FALSE, exdir = "E:/Wild_fire_project/Unzip_file/data")}
    
```    
    
