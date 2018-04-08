# TODO: Add comment
# 
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


#list classifed images
l8.class.50 <- "E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\L8_class50"
my.raster = list.files(l8.class.50, pattern=".tif$", full.names = T)

# get test data
setwd(l8.class.50)
test.50 <- readOGR(dsn='.',"l8_testData_50")
test.50 <- na.omit(test.50)
## determine uniqueClasses
#uniqueClasses <- rev(uniqueClasses)
uniqueClasses <- unique(test.50$Class)

cm.all3 <- NULL
for (i in 1:length(my.raster)) {
	#read in classified raster
	classified.rast <-  raster(my.raster[i]) #i
	
	#raster date #check that this applies to landsat 8 though
	r.date = unlist(strsplit(my.raster[i],"[_]")) #i # get raster date
	r.date = r.date[7]
	r.date
	
	## separate out test.data by data and ensure it matches the raster data
	test.dates <-test.50[test.50$Date == r.date,] # add the zeroback convert to 

	## read Rgeo book
	obs <- extract(classified.rast, test.dates) #these are our observation values in the classified raster. where 1 = H20, 2= SAV, 3 = EMR,
	#obs <-na.omit(obs)
	test.obs.factor <- uniqueClasses[obs] #what the image says it is
	val <- test.dates$Class # what my test data says it is
	
	## confusionMatrix of Random forest on the correct test data
	mod_RF_conMatrix <- confusionMatrix( data = test.obs.factor,
			reference = val) #make sure this just for the correct date
	mod_RF_conMatrix
	## save cm output
	cm <-capture.output(print(mod_RF_conMatrix), file = paste0(l8.class.50,
					"\\",r.date,"_CMoutput.txt"), append = TRUE)
	
	## add accuracy to a table use str(cm) to determine what the variables are called
	overall <- mod_RF_conMatrix$overall
	overall.accuracy <- overall['Accuracy']
	
	byC <- mod_RF_conMatrix$byClass
	prod.EMR <- byC['Class: EMR','Sensitivity']
	prod.FLT <- byC['Class: FLT','Sensitivity']
	prod.SAV <- byC['Class: SAV','Sensitivity']
	prod.water <- byC['Class: water','Sensitivity']
	user.EMR <- byC['Class: EMR','Pos Pred Value']
	user.FLT <- byC['Class: FLT','Pos Pred Value']
	user.SAV <- byC['Class: SAV','Pos Pred Value']
	user.water <- byC['Class: water','Pos Pred Value']
	
	cm.all= data.frame(r.date, overall.accuracy, prod.EMR, user.EMR, prod.FLT, user.FLT, prod.SAV, user.SAV, prod.water, user.water, row.names= NULL)
	cm.all3 = rbind(cm.all,cm.all3)
	
	rm(classified.rast)                          
	removeTmpFiles(h=0)
	#cma.cs = paste0(s5.class.dir, r.date,"_cm.csv")
	#find a way to iterate through column names 
}

write.csv(cm.all3, "L8_cm_Accuracy_updated_50.csv")



