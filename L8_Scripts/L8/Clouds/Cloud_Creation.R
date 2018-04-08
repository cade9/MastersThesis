# TODO: Add comment
# 12/1
# Author: cade
###############################################################################

mask.dir = "E:\\cade\\proj_S5T5_10_16_2016\\spot5take5\\Raster\\Masks\\L8_Masks\\mask_org_processed"
out.dir = "E:\\cade\\SPOT5Take5_11_25_2016\\Clouds_analysis\\"
list.all = list.files(path = mask.dir, full.names = T, pattern=".tif$")
stack.all = stack(list.all)
cc.sum = sum(stack.all)
cc.all <- cc.sum/12.0
writeRaster(cc.all,paste0(out.dir,"L8_CCA_all_S5box.tif"),format="GTiff", overwrite=T)


list.used <- list.files(path = mask.dir, full.names = T, pattern=".tif$")[-c(1,5,10,11,12)]	
stack.used = stack(list.used)
cc.sum.used = sum(stack.used)
plot(cc.sum.used)
cc.used <-cc.sum.used/7.00
plot(cc.used)
writeRaster(cc.used,paste0(out.dir,"L8_CCA_used_S5box.tif"),format="GTiff", overwrite=T)

## S5 create
memory.limit(size=10000)
setwd("E:\\cade\\proj_S5T5_10_16_2016\\spot5take5\\GIS")
boundingBox = readOGR(dsn="Clip_Boxes",layer ="s5t5_clipbox2")

s5.rep.dir <- "E:\\cade\\proj_S5T5_10_16_2016\\spot5take5\\Raster\\Masks\\Masks_NUA_rep\\by_occurance_div26"
s5.list.26 <- list.files(path=s5.rep.dir, full.names=T,pattern=".tif$")
s5.stack = stack(s5.list.26)
s5.sum <- sum(s5.stack)
writeRaster(s5.sum,paste0(out.dir,"S5_CCA_all_S5box.tif"),format="GTiff", overwrite=T )


