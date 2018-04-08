# TODO: Add comment
# 
# Author: cade
###############################################################################



l8.ref.dir = "E:\\cade\\proj_S5T5_10_16_2016\\spot5take5\\Raster\\Reflectance\\L8_Final_Ref"
l8.wavi.outdir = "E:\\cade\\SPOT5Take5_11_25_2016\\L8_WAVI"

setwd(l8.ref.dir)
l8.ref.list = list.files(l8.ref.dir,pattern = ".tif$",full.names=F)

for (i in 2:length(l8.ref.list)){
	l8.ref.stack <- stack(l8.ref.list[i])
	names(l8.ref.stack) <- c("B1","B2","B3","B4","B5","B6","B7")
	l8.wavi <- (1 + 0.5)*((l8.ref.stack[[5]] - l8.ref.stack[[2]])/(l8.ref.stack[[5]] + l8.ref.stack[[2]]+ 0.5))
	rastername = unlist(strsplit(l8.ref.list[i],"[_]"))
	rastername3=paste0(rastername[1],"_", rastername[2], "_WAVI")
	writeRaster(l8.wavi,paste0(l8.wavi.outdir,"\\",rastername3), format="GTiff", overwrite=T)
}


l8.wavi.list = list.files(l8.wavi.outdir, pattern = ".tif$",full.names=T)
#l8.ndvi.list = l8.ndvi.list[-5]
l8.wavi.stack = stack(l8.wavi.list)
writeRaster(l8.wavi.stack,"L8_wavi_stack.tif", format="GTiff", overwrite=T)

## remove the 160 because it si basically messing it up and check the nA values





