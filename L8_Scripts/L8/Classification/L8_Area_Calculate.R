# TODO: COMPUTES THE AREA  of each land cover 
# for landsat 8
#12/8 includes calculation of both for agu
# Author: cade
###############################################################################

##list of original classificatiosn to extract the dates
## do not need to read in the rasters
l8.class50 <- "E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\L8_class50"
l8.c.list <- list.files(l8.class50, pattern=".tif$")[-8]
mydates.all = NULL
for (i in 1:length(l8.c.list)) {
	mydates = unlist(strsplit(l8.c.list[i],"[_]")) ## i ##
	mydates2 = paste0("L8_",mydates[2])
	mydates.all = c(mydates.all,mydates2)
}

#stack of all classified images clipped to waterways
l8.all <- "E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\L8_class_stack_ww.tif"
l8.allClass <- stack(l8.all)
names(l8.allClass) <- mydates.all

#determine unique classes and pixel size, this will be used in the loop below
uniqueClasses <- unique(l8.allClass[[1]]) ## these are all going to be the same
resSat <- res(l8.allClass[[1]])

# set empty dataframe
area.all = data.frame(landcover = uniqueClasses)
for (i in 1:7){
	layer1 <- l8.allClass[[i]] #i
	#mydate = paste0(unlist(strsplit(names(layer1),"_"))[2],"_area_km2")
	mydate = unlist(strsplit(names(layer1),"_"))[2]
	layer.freq <- freq(layer1, useNA="no")
	area_km2 <- data.frame(area_km2 = layer.freq[,"count"] * prod(resSat) *1e-06)
	names(area_km2) <- mydate
	area.all <- cbind(area_km2,area.all)
}

l8.class501 <- "E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\"
write.csv(area.all, paste0(l8.class501,"area_L8_classes.csv"),row.names=FALSE)


area.all$landcover <- c("EMR","FLT","SAV","Water")
#melt to get in appropriate form for plotting
area.all.melt <- melt(area.all, id.vars='landcover')
names(area.all.melt) <- c("landcover","day","area_km2")
area.all.melt2 <- area.all.melt[rev(rownames(area.all.melt)),] # rev order 

##ggplot
p <-ggplot(area.all.melt2, aes(x=day,y=area_km2))
p + geom_area(aes(colour = landcover, fill = landcover), position="stack",size=3)


### empty raster

bR <- raster("E:\\cade\\SPOT5Take5_11_25_2016\\Stage_height\\BlankRasterwwEq0.tif")
resBr <- res(bR)
layer.freq <- freq(bR, useNA="no")
area_km2 <- data.frame(area_km2 = layer.freq[,"count"] * prod(resBr) *1e-06) #532.13651 from 0411
# in the future you need to check and see that the areas are all the same or at least somewhat the same
