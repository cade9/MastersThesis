
# TODO: Add comment
# Create classification csv like that of spot 5 take 5
# built off the classificationTable in s5 folder
# Author: cade
###############################################################################

require(RStoolbox)
require(raster)
require(randomForest)
require(caret)
require(e1071)
require(rgdal)
require(rgeos)
require(maptools)


### Create classification csv with all data

#set working directory for final reflectance products
setwd("D:\\proj\\spot5take5\\Raster\\Reflectance\\L8_Final_Ref")

# output and input directories
out.dir.classtable <- "D:\\proj\\spot5take5\\GIS\\L8_Classification_info"
out.dir.classimages <- "D:\\proj\\spot5take5\\Raster\\Products\\L8_ww_classified"
raster.dir = "D:\\proj\\spot5take5\\Raster\\Reflectance\\L8_Final_Ref"

# list all rasters 
l8.rast = list.files(getwd(), pattern = ".tif$")

#list all shapefiles
setwd("D:\\proj\\spot5take5\\GIS\\ROI_shp")
my.shp = list.files(".", pattern="*.shp$") 
my.shp.0720 <- my.shp[61:64]
#extract spectra
shp.ex = NULL 

for (i in 1:length(l8.rast)){
	for (j in 1:length(my.shp.0720)){
		
		#date for raster
		r.dates = unlist(strsplit(l8.rast[i],"[_]")) #i
		r.dates = r.dates[2]
		
		#read in raster brick
		my.brick = brick(paste0(raster.dir,"\\",l8.rast[i])) #i
		names(my.brick) <- c("Costal","Blue", "Green", "Red","NIR","SWIR1", "SWIR2")
		
		# read in shape
		layer.name = unlist(strsplit(my.shp.0720[j],"[.]")) #j
		layer.name = layer.name[1]
		layer.name
		
		#roi
		setwd("D:\\proj\\spot5take5\\GIS\\ROI_shp")
		roi = readOGR(dsn ='.', layer = layer.name)
		
		#shape file 0720 test
		#extract 
		my.extract <- extract(my.brick, roi, sp= T)
		my.extract$Date = paste(r.dates) # add date column
		my.extract = as.data.frame(my.extract) # set to dataframe
		my.extract = my.extract[-c(1)] # remove ID column
		my.extract <- my.extract[, c("Date", "Class", "Costal","Blue", "Green", "Red","NIR","SWIR1", "SWIR2","unqID","coords.x1","coords.x2")] #reorder col names
		shp.ex = rbind(my.extract,shp.ex) # add together
	}	
}

write.csv(shp.ex, file = "L8_0720_trainingDataCoords.csv",row.names=FALSE)


#########################################################################classification on test data
setwd("D:\\proj\\spot5take5")
shp.ex2 <- read.csv("GIS/ROI_shp/L8_0720_trainingDataCoords.csv", na.strings = NA)
shp.ex2 <- na.omit(shp.ex2)
shp.ex2$newID = paste0(shp.ex2$Date, "_", shp.ex2$Class, "_", ## train
				shp.ex2$coords.x1,"E_",shp.ex2$coords.x2,"N")

		############ set training and test
shp.ex.sp2 <-SpatialPointsDataFrame(shp.ex2[,c("coords.x1","coords.x2")],
		data = shp.ex2[1:13])
proj4string(shp.ex.sp2)=CRS("+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

############## split traing test
# http://stackoverflow.com/questions/23479512/stratified-random-sampling-from-data-frame-in-r
# http://stackoverflow.com/questions/33112082/removing-data-from-one-dataframe-that-exists-in-another-dataframe-r
# http://stackoverflow.com/questions/17338411/delete-rows-that-exist-in-another-data-frame
sp <- split(shp.ex.sp2, list(shp.ex.sp2$Date, shp.ex.sp2$Class))
samples <- lapply(sp, function(x) x[sample(1:nrow(x), size=0.3*nrow(x), FALSE),])
test1 <- do.call(rbind, samples)
train <- shp.ex.sp2[!(shp.ex.sp2$newID %in% test1$newID),]

setwd("D:\\proj\\spot5take5\\GIS\\ROI_shp")

write.csv(test1, "L8_test_0720.csv")
write.csv(train, "L8_train_0720.csv")
#test no dubs
#both <- rbind(test1, train)
#any(duplicated(both$newID))


######### random forest model 
#predict RF with test data:
mod_RF <- randomForest(Class ~ Green + Red + NIR + SWIR1, data = train, importance = T)
mod_RF
importance(mod_RF)
varImpPlot(mod_RF)

#apply to test data
mod_RF_test <- predict(mod_RF, test) #, type="class")

#confusionMatrix Random Forest
mod_RF_conMatrix <- confusionMatrix( data = mod_RF_test,
		reference = test$Class)
mod_RF_conMatrix 


###classify images

my.raster = list.files(path = raster.dir, pattern = ".tif$", full.names = T)
for (i in 1:length(l8.rast)) {
	
	#load in raster and get date
	l8.raster <- brick(my.raster[i]) #i
	names(l8.raster) <- c(c("Costal","Blue", "Green", "Red","NIR","SWIR1", "SWIR2"))
	r.date = unlist(strsplit(my.raster[i],"[_]")) #i
	r.date = r.date[4]
	r.date
	
	##apply prediction to image
	classified_rast <- predict(l8.raster,mod_RF)
	rastername2=paste0("L8_",r.date, "_classified1")
	writeRaster(classified_rast, paste0(out.dir.classimages,"\\",rastername2), format="GTiff",
	overwrite=T,datatype = "INT2S")
}

	




















### count
library(data.table)
dt <- as.data.table(shp.ex.sp2)
by.class = dt[,.(count= .N), by= .(Class,Date)]
library(tidyr)
by.Class.Table <- spread(data=by.class, key= Class, count)
by.Class.Table
