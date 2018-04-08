# TODO: Add comment
# 
# Author: cade
###############################################################################



##read in image with no change areas for spot 5
noChangedir = "E:\\cade\\SPOT5Take5_11_25_2016\\Class_nochange\\"
l8.class <- raster(paste0(noChangedir,"L8_staySame_NA_class_FINAL.tif"))
l8.class1 <- raster("E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\L8_staySame_classMasked_NA.tif")

setwd("E:\\cade\\SPOT5Take5_11_25_2016\\DifferentArea_CropBoxes")
bb <- readOGR(dsn ='.', "LibertyIsland")

l8.class <- mask(crop(l8.class1,bb),bb)


#### read in NDVI stack and set dates 
ndvi.stack= stack("E:\\cade\\SPOT5Take5_11_25_2016\\L8_ndvi\\L8_ndvi_stack_12imgENVI3.tif")
l8.list = list.files("E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\L8_class50", pattern = ".tif$")

mydates.all <- NULL


################################### S5 EMR ###############################
#create EMR layer
l8.class.EMR <-l8.class==1 
l8.class.EMR[l8.class.EMR != 1] <- NA 
#writeRaster(l8.class.EMR,"L8_nochange_EMR.tif")

l8.class.EMR <- raster(paste0(noChangedir,"L8_nochange_EMR.tif"))
# select random pixels 
set.seed(1) 
randomPixelsEMR <- sampleRandom(l8.class.EMR,size=1000, na.rm = T, sp= T,xy= T)

##NDVI stack
emr.ext <- extract(ndvi.stack,  randomPixelsEMR, df = T,na.rm=T)
emr.ext <- emr.ext[,-1]

names(emr.ext)<- c('04062015','04222015','05082015','05242015','060912015','06252015',
		'07112015','07272015','08122015','08282015','09132015','09292015')
emr.ext[emr.ext == "-Inf"]  <- NA 
emr.melt <- melt(emr.ext)
names(emr.melt) <- c("Date","NDVI")
emr.melt$Date = as.Date(emr.melt$Date,"%m%d%Y")

p = ggplot(data = emr.melt, aes(Date,NDVI))
p  + geom_point() +  stat_density2d(aes(fill=..level..), geom="polygon") +
		scale_fill_gradient(low="blue", high="green")+ scale_y_continuous(limits = c(-1, 1))

heatscatter(as.vector(emr.melt$Date),as.vector(emr.melt$NDVI), colpal="bl2gr2rd",ylim= c(0,1))


################################### S5 FLOATING ###############################
## S5 FLT
l8.class.FLT <-l8.class==2 
l8.class.FLT[l8.class.FLT != 1] <- NA 
writeRaster(l8.class.FLT,paste0(noChangedir,"L8_noChange_FLT.tif"))
#select random pixels
randomPixelsFLT <- sampleRandom(l8.class.FLT,size=1000, na.rm = T, sp= T,xy= T)
randomPixelsFLT <- randomPixelsFLT[-c(1:1117)]

flt.ext <- extract(ndvi.stack,  randomPixelsFLT, df = T,na.rm=T)
flt.ext <- flt.ext[,-1]

names(flt.ext)<- c('04062015','04222015','05082015','05242015','060912015','06252015',
		'07112015','07272015','08122015','08282015','09132015','09292015')
flt.ext[flt.ext == "-Inf"]  <- NA 
flt.melt <-melt(flt.ext)

names(flt.melt) <- c("Date","NDVI")
flt.melt$Date = as.Date(flt.melt$Date,"%m%d%Y")


f = ggplot(data = flt.melt, aes(Date,NDVI))
f  + geom_point() +  stat_density2d(aes(fill=..level..), geom="polygon") +
		scale_fill_gradient(low="blue", high="green")+ scale_y_continuous(limits = c(-1, 1))

heatscatter(as.vector(flt.melt$Date),as.vector(flt.melt$NDVI), colpal="bl2gr2rd",ylim= c(0,1))

write.csv(flt.melt,paste0(noChangedir,"flt_melt.csv"))

