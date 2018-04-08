# TODO: Add comment
# Merge (mosaic) L8 33 to 34
# Author: cade
###############################################################################

require(raster)
require(gdal)
require(gdalUtils)

#read in list of rasters
setwd("D:\\proj\\spot5take5\\Raster\\Reflectance\\L8_SF_Bay")
list.L8.33 = list.files("./L8_33_Mask", pattern=".tif$",ignore.case=TRUE)
list.L8.34 = list.files("./L8_34_Crop", pattern=".tif$", ignore.case=TRUE)


### next thing to try is to read the whole thing in
setwd("D:\\proj\\spot5take5\\Raster\\Reflectance\\L8_SF_Bay\\Cliptrial")
list.L8 = list.files(getwd(), pattern=".tif$",ignore.case=TRUE)
list.L8.33 = c(list.L8[1],list.L8[3]) 
list.L8.34 = c(list.L8[2],list.L8[4])
mask.33 = brick(list.L8.33[1])
NAvalue(mask.33) <- -9999
mask.34 = raster(list.L8.34[1])
NAvalue(mask.34) <- -9999
both.merge = merge(mask.34, mask.33, overlap = F)



for (i in 1:1) {
	mask.33 = brick(list.L8.33[1])
	NAvalue(mask.33) <- -9999
	mask.34 = raster(list.L8.34[1])
	NAvalue(mask.34) <- -9999
	both.merge = merge(mask.34, mask.33, overlap = F)
	rastername=unlist(strsplit(list.L8.34[i],"[.]"))
	rastername2=paste0(rastername[1], "_merge")
	writeRaster(both.merge, paste0("merge\\",rastername2), format="GTiff", overwrite=T)
	rm(mask.33)
	rm(mask.34)
	rm(both.merge)
	removeTmpFiles(h=0)
}



batch_gdal_translate(infiles=Input,outdir=Input,outsuffix="")

list.L8.33[1]

