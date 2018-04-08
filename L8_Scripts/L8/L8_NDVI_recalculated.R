# TODO: Add comment
# 
# Author: cade
###############################################################################

l8.ref.dir = "D:\\proj\\spot5take5\\Raster\\Reflectance\\L8_Final_Ref"
l8.ndvi.outdir = "D:\\proj\\spot5take5\\Raster\\Products\\L8_ndvi"

setwd(l8.ref.dir)
l8.ref.list = list.files(l8.ref.dir,pattern = ".tif$",full.names=F)

for (i in 2:length(l8.ref.list)){
	l8.ref.stack <- stack(l8.ref.list[i])
	names(l8.ref.stack) <- c("B1","B2","B3","B4","B5","B6","B7")
	l8.ndvi <- spectralIndices(l8.ref.stack, red = "B4", nir ="B5", indices = "NDVI")
	rastername = unlist(strsplit(l8.ref.list[i],"[_]"))
	rastername3=paste0(rastername[1],"_", rastername[2], "_NDVI")
	writeRaster(l8.ndvi,paste0(l8.ndvi.outdir,"\\",rastername3), format="GTiff", overwrite=T)
}

setwd("D:\\proj\\spot5take5\\Raster\\Products\\L8_ndvi")
l8.ndvi.list = list.files(l8.ndvi.outdir, pattern = ".tif$",full.names=T)
l8.ndvi.list = l8.ndvi.list[-5]
l8.ndvi.stack = stack(l8.ndvi.list)
writeRaster(l8.ndvi.stack,"L8_ndvi_stack_no160.tif", format="GTiff", overwrite=T)

## remove the 160 because it si basically messing it up and check the nA values




