# TODO: Cleaned up version of add_unqID_toshp.R
# DATE: 11/26/2016
# This adds a class column and a unqID column to the shapefiles that have been created from photo-interpretation 
# 
# NOTES: line 18 can be changed for particular date using 
# my.shp = list.files(".", pattern="0421.*shp$") # select a particular date
# Author: cade
###############################################################################

##require packages
require(raster)
require(rgdal)
require(rgeos)
require(maptools)
require(sp)

## set working directory and create shapefile character vector 
setwd("E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\ROI_shp")
my.shp = list.files(".", pattern=".shp$")
my.shp

out.dir ="E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\ROI_uni" #does not overwrite the shapefiles

## add coordinates 
for (i in 3:length(my.shp)) {
	
	# date
	myname = unlist(strsplit(my.shp[i],"[_]")) #i
	s.dates = myname[1]
	s.dates 
	
	# class
	my.class1 = unlist(strsplit(myname[2],"[.]"))
	my.class = my.class1[1]
	my.class
	
	# use to read in shapefile
	layer.name = unlist(strsplit(my.shp[i],"[.]")) #i
	layer.name = layer.name[1]
	layer.name
	
	# read in shapefile
	roi = readOGR(dsn ='.', layer = layer.name)
	proj4string(roi)=CRS("+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
	
	# add class column
	roi$Class = my.class
	# add uniqueID
	coordNE <- coordinates(roi)
	colnames(coordNE) <- c("E","N")
	coordNE <-as.data.frame(coordNE)
	coordNE$x <- paste(s.dates,"_",my.class,"_",coordNE$E,"E_",coordNE$N,"N")
	newcoord <- as.data.frame(apply(coordNE,2,function(x)gsub('\\s+', '',x))) # you don't need this this just gets rid of blank space which is what paste0 does
	roi$unqID <- newcoord$x
	writeOGR(roi,dsn=out.dir, layer = paste0(layer.name), driver= "ESRI Shapefile",overwrite_layer= T)
	
}


