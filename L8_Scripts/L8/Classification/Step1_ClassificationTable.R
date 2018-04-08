# TODO: Add comment
# 
# Author: cade
###############################################################################

## raster list
rast.dir = "E:\\cade\\proj_11_28_2015\\Raster\\Reflectance\\L8_Final_Ref" #where rasters live
my.raster = list.files(rast.dir,pattern =".tif$")[-c(1,5,10,11,12)]	  # delete ones with no training data

## shapefile list
setwd("E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\ROI_uni")
my.shp = list.files(".", pattern="*.shp$") 
################################################### PART1: LOOP  ###########################################

shp.ex = NULL #empty list for extracting of shapefiles, must append to this list

# loop for extraction
for (i in 1:length(my.raster)) {
	for (j in 1:length(my.shp)){
		
		# date for raster
		r.dates = unlist(strsplit(my.raster[i],"[_]")) #i
		r.dates = r.dates[2]
		r.dates
		
		# read in raster
		my.brick = brick(paste0(rast.dir,"\\",my.raster[4])) #i
		names(my.brick) <-c("Aerosol","Blue","Green","Red","NIR","SWIR","SWIR2")
		
		# shapefile date
		s.dates1 = unlist(strsplit(my.shp[j],"[_]")) #j
		s.dates = s.dates1[1]
		s.dates 
		
		# shapefile class
		my.class = unlist(strsplit(s.dates1[2],"[.]")) 
		my.class = my.class[1]
		my.class
		
		# use to read in raster
		layer.name = unlist(strsplit(my.shp[j],"[.]")) #j
		layer.name = layer.name[1]
		layer.name
		
		# read in roi
		roi = readOGR(dsn ='.', layer = layer.name)
		roi = roi[,!names(roi) %in% "ID"] # delete layer name
		
		if(r.dates == s.dates){
			my.extract = extract(my.brick, roi,sp =T) #when you convert from sp to df it adds coord columns
			my.extract$Date = paste(r.dates)
			my.extract = as.data.frame(my.extract, row.names = NULL)
			my.extract <- my.extract[, c("Date", "Class", "Aerosol","Blue","Green","Red","NIR","SWIR","SWIR2","unqID","coords.x1","coords.x2")]
			shp.ex= rbind(my.extract,shp.ex)
		} else {
			print("Doesn't Match")
		}
	}
}

################################################### PART2: WRITE TO CSV  ###########################################
class.table.out <- "E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification"
write.csv(shp.ex, file = paste0(class.table.out,"\\","L8_trainingData_updated.csv"),row.names=FALSE)

###did not actually run 
shp.ex.sp <-SpatialPoints(coords=shp.ex[,c("coords.x1","coords.x2")]) #page 73
writeOGR(shp.ex.sp,dsn=out.dir, layer = "all_training", driver= "ESRI Shapefile",overwrite_layer= T)


