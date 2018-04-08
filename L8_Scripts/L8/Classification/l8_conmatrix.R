# TODO: Add comment
# 
# Author: cade
###############################################################################

l8.class.dir <- "D:\\proj\\spot5take5\\Raster\\Products\\L8_ww_classified"
l8.train <- read.csv("D:\\proj\\spot5take5\\GIS\\ROI_shp\\L8_train_0720.csv",
		header = T, na.strings = NA)
l8.test.data <- read.csv("D:\\proj\\spot5take5\\GIS\\ROI_shp\\L8_test_0720.csv" ,
		header = T, na.strings = NA)

cm.all = NULL
my.raster = list.files(l8.class.dir, pattern=".tif$", full.names = T)

for (i in 1:length(my.raster)) {
	#read in classified raster
	classified.rast <-  brick(my.raster[2])
	
	#raster date #check that this applies to landsat 8 though
	r.date = unlist(strsplit(my.raster[2],"[_]")) #i # get raster date
	r.date = r.date[3]
	r.date = substr(r.date,12,15)
	r.date
	
	## separate out test.data by data and ensure it matches the raster data
	test.dates <-l8.test.data[l8.test.data$Date == r.date,]

	
	obs <- extract(classified.rast, test.dates)
	#obs <-na.omit(obs)
	test.obs.factor <- uniqueClasses[obs]
	val <- test.dates$Class
	
	## confusionMatrix of Random forest on the correct test data
	mod_RF_conMatrix <- confusionMatrix( data = test.obs.factor,
			reference = val,) #make sure this just for the correct date
	
	## add accuracy to a table use str(cm) to determine what the variables are called
	overall <- mod_RF_conMatrix$overall
	overall.accuracy <- overall['Accuracy']
	
	byC <- mod_RF_conMatrix$byClass
	pos.EMR <- byC['Class: EMR','Pos Pred Value']
	pos.FLT <- byC['Class: FLT','Pos Pred Value']
	pos.SAV <- byC['Class: SAV','Pos Pred Value']
	pos.water <- byC['Class: water','Pos Pred Value']
	neg.EMR <- byC['Class: EMR','Neg Pred Value']
	neg.FLT <- byC['Class: FLT','Neg Pred Value']
	neg.SAV <- byC['Class: SAV','Neg Pred Value']
	neg.water <- byC['Class: water','Neg Pred Value']
	cm.all= cbind(overall.accuracy, pos.EMR,pos.FLT,pos.SAV,pos.water,neg.EMR, neg.FLT, neg.SAV, neg.water, cm.all)	
	#find a way to iterate through column names 
}
